use std::ops::Add;
use std::ops::Neg;

use k256::EncodedPoint;
use k256::ProjectivePoint;
use k256::elliptic_curve::BatchNormalize;
use k256::elliptic_curve::sec1::FromEncodedPoint;
use plonky2::field::extension::Extendable;
use plonky2::field::secp256k1_scalar::Secp256K1Scalar;
use plonky2::field::types::Field;
use plonky2::hash::hash_types::RichField;
use plonky2::iop::target::Target;
use plonky2::plonk::circuit_builder::CircuitBuilder;
use plonky2_ecdsa::curve::curve_types::AffinePoint;
use plonky2_ecdsa::curve::curve_types::Curve;
use plonky2_ecdsa::curve::secp256k1::Secp256K1;
use plonky2_ecdsa::gadgets::curve::AffinePointTarget;
use plonky2_ecdsa::gadgets::curve::CircuitBuilderCurve;
use plonky2_ecdsa::gadgets::curve_windowed_mul::CircuitBuilderWindowedMul;
use plonky2_ecdsa::gadgets::nonnative::NonNativeTarget;
use plonky2_ecdsa::gadgets::split_nonnative::CircuitBuilderSplit;

use crate::curve::utils::encoded_point_from_compressed_public_key;
use crate::curve::utils::k256_affine_point_to_plonky2_affine_point;
use crate::curve::utils::plonky2_affine_point_to_k256_affine_point;

pub fn precompute_mul_table(point: AffinePoint<Secp256K1>) -> Vec<Vec<AffinePoint<Secp256K1>>> {
    let point = plonky2_affine_point_to_k256_affine_point(point);

    let before = std::time::Instant::now();
    let rand = k256::ProjectivePoint::from(get_rand());
    let point_projective: k256::ProjectivePoint = k256::ProjectivePoint::from(point);

    let mut table_proj =
        vec![vec![k256::ProjectivePoint::IDENTITY; WIDTH as usize]; LIMBS as usize];

    let base_table_start_time = std::time::Instant::now();
    for i in 0..LIMBS as usize {
        if i == 0 {
            table_proj[i][1] = point_projective;
        } else {
            table_proj[i][1] = table_proj[i - 1][WIDTH as usize / 2].double();
        }
        for j in 2..WIDTH as usize {
            if j % 2 == 0 {
                table_proj[i][j] = table_proj[i][j / 2].double();
            } else {
                table_proj[i][j] = table_proj[i][j - 1].add(table_proj[i][1]);
            }
        }
    }
    eprintln!(
        "base_table took {:?}ms",
        base_table_start_time.elapsed().as_micros() as f32 / 1000.0
    );

    let add_rand_start_time = std::time::Instant::now();
    for row in table_proj.iter_mut() {
        for element in row.iter_mut() {
            *element = element.add(rand);
        }
    }
    eprintln!(
        "add rand took {:?}ms",
        add_rand_start_time.elapsed().as_micros() as f32 / 1000.0
    );

    let to_affine_start_time = std::time::Instant::now();

    let flattened_table: [ProjectivePoint; (LIMBS * WIDTH) as usize] = table_proj
        .into_iter()
        .flatten()
        .collect::<Vec<ProjectivePoint>>()
        .try_into()
        .unwrap();

    let table: Vec<Vec<k256::AffinePoint>> =
        k256::ProjectivePoint::batch_normalize(&flattened_table)
            .chunks(WIDTH as usize)
            .map(|chunk| chunk.to_vec())
            .collect();
    eprintln!(
        "to affine took {:?}ms",
        to_affine_start_time.elapsed().as_micros() as f32 / 1000.0
    );

    eprintln!(
        "mul_table took (total) {:?}ms",
        before.elapsed().as_micros() as f32 / 1000.0
    );

    table
        .into_iter()
        .map(|inner| {
            inner
                .into_iter()
                .map(k256_affine_point_to_plonky2_affine_point)
                .collect()
        })
        .collect()
}

fn get_rand() -> k256::AffinePoint {
    let encoded_point: EncodedPoint = encoded_point_from_compressed_public_key(
        hex::decode("03123456789abcdeffedcba9876543210f0e1d0000000000000000000000000000")
            .unwrap()
            .try_into()
            .unwrap(),
    )
    .unwrap();

    k256::AffinePoint::from_encoded_point(&encoded_point).unwrap()
}

fn get_another_rand() -> k256::AffinePoint {
    let encoded_point: EncodedPoint = encoded_point_from_compressed_public_key(
        hex::decode("032eb7b7fd1da366b551ef5c946ac0719fbafa846ef7cdf681611bf6b1fa01c9eb")
            .unwrap()
            .try_into()
            .unwrap(),
    )
    .unwrap();

    k256::AffinePoint::from_encoded_point(&encoded_point).unwrap()
}

pub trait CircuitBuilderFixed {
    fn add_virtual_mul_table_target(&mut self) -> PrecomputedMulTableTarget;

    fn add_const_mul_table_target(
        &mut self,
        point: AffinePoint<Secp256K1>,
    ) -> PrecomputedMulTableTarget;

    fn add_basepoint_mul_table(&mut self) -> PrecomputedMulTableTarget;

    fn scalar_mul(
        &mut self,
        table: &PrecomputedMulTableTarget,
        value: &NonNativeTarget<Secp256K1Scalar>,
    ) -> AffinePointTarget<Secp256K1>;
}

#[derive(Clone)]
pub struct PrecomputedMulTableTarget {
    correction: AffinePointTarget<Secp256K1>,
    pub limbs: Vec<Vec<AffinePointTarget<Secp256K1>>>,
}

pub const LIMBS: u32 = 256 / 4;
pub const WIDTH: u32 = 1 << 4;

impl<F: RichField + Extendable<D>, const D: usize> CircuitBuilderFixed for CircuitBuilder<F, D> {
    fn add_basepoint_mul_table(&mut self) -> PrecomputedMulTableTarget {
        self.add_const_mul_table_target(Secp256K1::GENERATOR_AFFINE)
    }

    fn add_const_mul_table_target(
        &mut self,
        point: AffinePoint<Secp256K1>,
    ) -> PrecomputedMulTableTarget {
        let vals = precompute_mul_table(point);
        let rand = k256_affine_point_to_plonky2_affine_point(get_rand());
        let neg_limbs = -Secp256K1Scalar::from_noncanonical_u128(LIMBS as u128);
        let correction = Secp256K1::convert(neg_limbs) * rand.to_projective();
        let correction = self.constant_affine_point(correction.to_affine());
        PrecomputedMulTableTarget {
            correction,
            limbs: vals
                .into_iter()
                .map(|v| {
                    v.into_iter()
                        .map(|point| self.constant_affine_point(point))
                        .collect()
                })
                .collect(),
        }
    }
    fn add_virtual_mul_table_target(&mut self) -> PrecomputedMulTableTarget {
        let rand = k256_affine_point_to_plonky2_affine_point(get_rand());
        let neg_limbs = -Secp256K1Scalar::from_noncanonical_u128(LIMBS as u128);
        let correction = Secp256K1::convert(neg_limbs) * rand.to_projective();
        let correction = self.constant_affine_point(correction.to_affine());
        PrecomputedMulTableTarget {
            correction,
            limbs: (0..LIMBS)
                .map(|_| {
                    (0..WIDTH)
                        .map(|_| self.add_virtual_affine_point_target())
                        .collect()
                })
                .collect(),
        }
    }

    fn scalar_mul(
        &mut self,
        table: &PrecomputedMulTableTarget,
        value: &NonNativeTarget<Secp256K1Scalar>,
    ) -> AffinePointTarget<Secp256K1> {
        let value_as_4bits_limbs = self.split_nonnative_to_4_bit_limbs(value);
        let value_as_4bits_limbs_padded = pad_4bits_limbs_to_256bits(self, value_as_4bits_limbs);

        let addends: Vec<_> = value_as_4bits_limbs_padded
            .into_iter()
            .enumerate()
            .map(|(i, k)| self.random_access_curve_points(k, table.limbs[i].clone()))
            .collect();

        let rand = k256_affine_point_to_plonky2_affine_point(get_another_rand());
        let mut sum = self.constant_affine_point(rand);
        let neg_rand = self.constant_affine_point(rand.neg());
        for addend in addends {
            sum = self.curve_add(&sum, &addend);
        }
        sum = self.curve_add(&sum, &neg_rand);
        sum = self.curve_add(&sum, &table.correction);

        sum
    }
}
fn pad_4bits_limbs_to_256bits<F: RichField + Extendable<D>, const D: usize>(
    builder: &mut CircuitBuilder<F, D>,
    mut value_as_4bits_limbs: Vec<Target>,
) -> Vec<Target> {
    let u256_as_4_bits_limbs_count = 64;
    (0..u256_as_4_bits_limbs_count - value_as_4bits_limbs.len())
        .for_each(|_| value_as_4bits_limbs.push(builder.zero()));

    value_as_4bits_limbs
}

#[cfg(test)]
mod tests {
    use num::BigUint;
    use num::Num;
    use plonky2::field::goldilocks_field::GoldilocksField;
    use plonky2::field::secp256k1_base::Secp256K1Base;
    use plonky2::field::secp256k1_scalar::Secp256K1Scalar;
    use plonky2::field::types::Field;
    use plonky2::iop::witness::PartialWitness;
    use plonky2::plonk::circuit_builder::CircuitBuilder;
    use plonky2::plonk::circuit_data::CircuitConfig;
    use plonky2::plonk::config::GenericConfig;
    use plonky2::plonk::config::KeccakGoldilocksConfig;
    use plonky2_ecdsa::curve::curve_types::AffinePoint;
    use plonky2_ecdsa::curve::curve_types::Curve;
    use plonky2_ecdsa::curve::secp256k1::Secp256K1;
    use plonky2_ecdsa::gadgets::curve::CircuitBuilderCurve;
    use plonky2_ecdsa::gadgets::curve::WitnessPoint;
    use plonky2_ecdsa::gadgets::nonnative::CircuitBuilderNonNative;
    use plonky2_ecdsa::gadgets::nonnative::WitnessNonNative;

    use super::CircuitBuilderFixed;
    use super::LIMBS;
    use super::WIDTH;
    use super::precompute_mul_table;

    type C = KeccakGoldilocksConfig;
    type F = <C as GenericConfig<2>>::F;

    fn new_test_circuit_builder() -> CircuitBuilder<GoldilocksField, 2> {
        let config = CircuitConfig::wide_ecc_config();
        CircuitBuilder::<F, 2>::new(config)
    }

    fn test_circuit_generator_multiplication_with_tables_and_constants(
        scalar_field_element: Secp256K1Scalar,
        expected_multiplication_result_x: Secp256K1Base,
        expected_multiplication_result_y: Secp256K1Base,
    ) {
        let mut builder = new_test_circuit_builder();
        let table = builder.add_basepoint_mul_table();
        let scalar_field_element_target = builder.constant_nonnative(scalar_field_element);
        let point = AffinePoint::<Secp256K1> {
            x: expected_multiplication_result_x,
            y: expected_multiplication_result_y,
            zero: false,
        };
        let expected_result = builder.constant_affine_point(point);
        let generated_point = builder.scalar_mul(&table, &scalar_field_element_target);

        builder.connect_affine_point(&generated_point, &expected_result);

        let pw = PartialWitness::<GoldilocksField>::new();
        let data = builder.build::<C>();
        let proof = data.prove(pw.clone()).unwrap();
        assert!(data.verify(proof).is_ok())
    }

    fn test_circuit_generator_multiplication_with_tables_and_inputs(
        scalar_field_element: Secp256K1Scalar,
        expected_multiplication_result_x: Secp256K1Base,
        expected_multiplication_result_y: Secp256K1Base,
    ) {
        let mut builder = new_test_circuit_builder();
        let table = builder.add_basepoint_mul_table();

        let scalar_field_element_target = builder.add_virtual_nonnative_target();

        let point = AffinePoint::<Secp256K1> {
            x: expected_multiplication_result_x,
            y: expected_multiplication_result_y,
            zero: false,
        };
        let expected_result = builder.constant_affine_point(point);
        let generated_point = builder.scalar_mul(&table, &scalar_field_element_target);

        builder.connect_affine_point(&generated_point, &expected_result);

        let mut pw = PartialWitness::<GoldilocksField>::new();
        pw.set_non_native_target(&scalar_field_element_target, &scalar_field_element);
        let data = builder.build::<C>();
        let proof = data.prove(pw.clone()).unwrap();
        assert!(data.verify(proof).is_ok())
    }

    fn test_circuit_for_point(
        scalar_field_element: Secp256K1Scalar,
        point: AffinePoint<Secp256K1>,
        expected_multiplication_result_x: Secp256K1Base,
        expected_multiplication_result_y: Secp256K1Base,
    ) {
        let mut builder = new_test_circuit_builder();

        // Circuit
        let scalar_field_element_target = builder.add_virtual_nonnative_target();
        let table = builder.add_virtual_mul_table_target();
        let generated_point = builder.scalar_mul(&table, &scalar_field_element_target);
        let expected_point = AffinePoint::<Secp256K1> {
            x: expected_multiplication_result_x,
            y: expected_multiplication_result_y,
            zero: false,
        };
        let expected_result = builder.constant_affine_point(expected_point);
        builder.connect_affine_point(&generated_point, &expected_result);

        //Witness
        let mut pw = PartialWitness::<GoldilocksField>::new();
        pw.set_non_native_target(&scalar_field_element_target, &scalar_field_element);

        let table_data = precompute_mul_table(point);

        assert_eq!(table.limbs.len(), LIMBS as usize);
        assert_eq!(table_data.len(), LIMBS as usize);

        for (mul_row, data_row) in table.limbs.iter().zip(table_data) {
            assert_eq!(mul_row.len(), WIDTH as usize);
            assert_eq!(data_row.len(), WIDTH as usize);
            for (mul_element, data_element) in mul_row.iter().zip(data_row) {
                pw.set_affine_point_target(mul_element, &data_element.x, &data_element.y);
            }
        }

        let data = builder.build::<C>();
        let proof = data.prove(pw).unwrap();
        assert!(data.verify(proof).is_ok())
    }

    #[test]
    fn test_can_multiply_curve_point_with_tables_with_constants() {
        let parsed_scalar_field_element = "7730c781f7ae53";

        let parsed_expected_result_x =
            "933ec2d2b111b92737ec12f1c5d20f3233a0ad21cd8b36d0bca7a0cfa5cb8701";
        let parsed_expected_result_y =
            "96cbbfdd572f75ace44d0aa59fbab6326cb9f909385dcd066ea27affef5a488c";

        let scalar_field_element = Secp256K1Scalar::from_noncanonical_biguint(
            BigUint::from_str_radix(parsed_scalar_field_element, 16).unwrap(),
        );
        let expected_result_x = Secp256K1Base::from_noncanonical_biguint(
            BigUint::from_str_radix(parsed_expected_result_x, 16).unwrap(),
        );
        let expected_result_y = Secp256K1Base::from_noncanonical_biguint(
            BigUint::from_str_radix(parsed_expected_result_y, 16).unwrap(),
        );

        test_circuit_generator_multiplication_with_tables_and_constants(
            scalar_field_element,
            expected_result_x,
            expected_result_y,
        );
    }

    #[test]
    fn test_can_multiply_curve_point_with_tables() {
        let parsed_scalar_field_element = "7730c781f7ae53";

        let parsed_expected_result_x =
            "933ec2d2b111b92737ec12f1c5d20f3233a0ad21cd8b36d0bca7a0cfa5cb8701";
        let parsed_expected_result_y =
            "96cbbfdd572f75ace44d0aa59fbab6326cb9f909385dcd066ea27affef5a488c";

        let scalar_field_element = Secp256K1Scalar::from_noncanonical_biguint(
            BigUint::from_str_radix(parsed_scalar_field_element, 16).unwrap(),
        );
        let expected_result_x = Secp256K1Base::from_noncanonical_biguint(
            BigUint::from_str_radix(parsed_expected_result_x, 16).unwrap(),
        );
        let expected_result_y = Secp256K1Base::from_noncanonical_biguint(
            BigUint::from_str_radix(parsed_expected_result_y, 16).unwrap(),
        );

        test_circuit_generator_multiplication_with_tables_and_inputs(
            scalar_field_element,
            expected_result_x,
            expected_result_y,
        );
    }

    #[test]
    fn test_base_multiplication_as_public_input() {
        let parsed_scalar_field_element = "7730c781f7ae53";

        let parsed_expected_result_x =
            "933ec2d2b111b92737ec12f1c5d20f3233a0ad21cd8b36d0bca7a0cfa5cb8701";
        let parsed_expected_result_y =
            "96cbbfdd572f75ace44d0aa59fbab6326cb9f909385dcd066ea27affef5a488c";

        let scalar_field_element = Secp256K1Scalar::from_noncanonical_biguint(
            BigUint::from_str_radix(parsed_scalar_field_element, 16).unwrap(),
        );
        let expected_result_x = Secp256K1Base::from_noncanonical_biguint(
            BigUint::from_str_radix(parsed_expected_result_x, 16).unwrap(),
        );
        let expected_result_y = Secp256K1Base::from_noncanonical_biguint(
            BigUint::from_str_radix(parsed_expected_result_y, 16).unwrap(),
        );

        test_circuit_for_point(
            scalar_field_element,
            Secp256K1::GENERATOR_AFFINE,
            expected_result_x,
            expected_result_y,
        )
    }
}
