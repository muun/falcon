use log::debug;
use plonky2::field::extension::Extendable;
use plonky2::field::secp256k1_scalar::Secp256K1Scalar;
use plonky2::field::types::Field;
use plonky2::hash::hash_types::RichField;
use plonky2::iop::target::BoolTarget;
use plonky2::plonk::circuit_builder::CircuitBuilder;
use plonky2::plonk::circuit_data::CircuitConfig;
use plonky2::plonk::circuit_data::CircuitData;
use plonky2::plonk::config::GenericConfig;
use plonky2::plonk::config::KeccakGoldilocksConfig;
use plonky2_ecdsa::curve::secp256k1::Secp256K1;
use plonky2_ecdsa::gadgets::biguint::BigUintTarget;
use plonky2_ecdsa::gadgets::curve::AffinePointTarget;
use plonky2_ecdsa::gadgets::curve::CircuitBuilderCurve;
use plonky2_ecdsa::gadgets::nonnative::CircuitBuilderNonNative;
use plonky2_ecdsa::gadgets::nonnative::NonNativeTarget;
use plonky2_sha256::circuit::bits_to_u32_target;
use plonky2_sha256::circuit::make_circuits;

use crate::curve::point_mul::CircuitBuilderFixed;
use crate::curve::point_mul::LIMBS;
use crate::curve::point_mul::PrecomputedMulTableTarget;
use crate::curve::point_mul::WIDTH;
use crate::inputs::TargetInputs;

pub const D: usize = 2;
pub type C = KeccakGoldilocksConfig;
pub type F = <C as GenericConfig<D>>::F;

pub struct Circuit {
    pub circuit: CircuitData<F, C, D>,
    pub target_inputs: TargetInputs,
}

impl Circuit {
    pub fn build() -> Self {
        let config = CircuitConfig {
            zero_knowledge: true,
            ..CircuitConfig::standard_ecc_config()
        };
        let mut builder = CircuitBuilder::<F, D>::new(config);

        // Private inputs
        let server_ephemeral_private_key: NonNativeTarget<Secp256K1Scalar> =
            builder.add_virtual_nonnative_target();

        // Public inputs
        let server_ephemeral_public_key = builder.add_virtual_affine_point_target();
        let pad_public_key = builder.add_virtual_affine_point_target();
        let recovery_code_mul_table = builder.add_virtual_mul_table_target();

        let basepoint_mul_table = builder.add_basepoint_mul_table();

        // Assert pub_eph == priv_eph G
        Self::assert_public_key_matches_with_private_key(
            &mut builder,
            &basepoint_mul_table,
            &server_ephemeral_private_key,
            &server_ephemeral_public_key,
        );

        Self::assert_public_pad_is_correct(
            &mut builder,
            &server_ephemeral_private_key,
            &pad_public_key,
            &basepoint_mul_table,
            &recovery_code_mul_table,
        );

        // Register public inputs
        Self::register_public_affine_point(&mut builder, &server_ephemeral_public_key);
        Self::register_public_affine_point(&mut builder, &pad_public_key);
        Self::register_public_mul_table(&mut builder, &recovery_code_mul_table);

        let inputs = TargetInputs::new(
            server_ephemeral_private_key,
            server_ephemeral_public_key,
            pad_public_key,
            recovery_code_mul_table,
        );

        debug!("num_gates = {}", builder.num_gates());

        Self {
            circuit: builder.build::<C>(),
            target_inputs: inputs,
        }
    }

    fn assert_public_pad_is_correct(
        builder: &mut CircuitBuilder<F, D>,
        server_ephemeral_private_key: &NonNativeTarget<Secp256K1Scalar>,
        expected_pad_public_key: &AffinePointTarget<Secp256K1>,
        basepoint_mul_table: &PrecomputedMulTableTarget,
        recovery_code_mul_table: &PrecomputedMulTableTarget,
    ) {
        // Compute shared_key
        let shared_key = builder.scalar_mul(recovery_code_mul_table, server_ephemeral_private_key);

        let x_bits = builder.split_nonnative_to_bits(&shared_key.x);
        let sha_256_targets = make_circuits(builder, 256);
        for (i, _) in x_bits.iter().enumerate().take(256) {
            builder.connect(x_bits[i].target, sha_256_targets.message[255 - i].target);
        }

        let pad_private = bits_be_to_biguint_target(builder, sha_256_targets.digest);
        let pad_private_as_scalar_field = builder.reduce::<Secp256K1Scalar>(&pad_private);

        // assert priv_pad *G == Pub_Pad
        Self::assert_public_key_matches_with_private_key(
            builder,
            basepoint_mul_table,
            &pad_private_as_scalar_field,
            expected_pad_public_key,
        );
    }

    fn assert_public_key_matches_with_private_key(
        builder: &mut CircuitBuilder<F, D>,
        basepoint_mul_table: &PrecomputedMulTableTarget,
        private_key: &NonNativeTarget<Secp256K1Scalar>,
        expected_public_key: &AffinePointTarget<Secp256K1>,
    ) {
        let public_key = builder.scalar_mul(basepoint_mul_table, private_key);
        builder.connect_affine_point(&public_key, expected_public_key);
    }

    fn register_public_affine_point(
        builder: &mut CircuitBuilder<F, D>,
        public_key_target: &AffinePointTarget<Secp256K1>,
    ) {
        Self::register_public_nonnative(builder, &public_key_target.x);
        Self::register_public_nonnative(builder, &public_key_target.y);
    }

    fn register_public_nonnative<T: Field, F: RichField + Extendable<D>, const D: usize>(
        builder: &mut CircuitBuilder<F, D>,
        target: &NonNativeTarget<T>,
    ) {
        builder.register_public_inputs(
            &target
                .value
                .limbs
                .iter()
                .map(|limb| limb.0)
                .collect::<Vec<_>>(),
        );
    }
    fn register_public_mul_table<F: RichField + Extendable<D>, const D: usize>(
        builder: &mut CircuitBuilder<F, D>,
        table: &PrecomputedMulTableTarget,
    ) {
        for i in 0..LIMBS as usize {
            for j in 0..WIDTH as usize {
                Self::register_public_nonnative(builder, &table.limbs[i][j].x);
                Self::register_public_nonnative(builder, &table.limbs[i][j].y);
            }
        }
    }
}

fn bits_be_to_biguint_target<F: RichField + Extendable<D>, const D: usize>(
    builder: &mut CircuitBuilder<F, D>,
    bits_be: Vec<BoolTarget>,
) -> BigUintTarget {
    BigUintTarget {
        limbs: bits_be
            .chunks(32)
            .map(|chunk| bits_to_u32_target(builder, chunk.to_owned()))
            .rev()
            .collect(),
    }
}
