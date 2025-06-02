use anyhow::Error;
use plonky2::field::secp256k1_base::Secp256K1Base;
use plonky2::field::secp256k1_scalar::Secp256K1Scalar;
use plonky2::iop::witness::PartialWitness;
use plonky2_ecdsa::curve::curve_types::AffinePoint;
use plonky2_ecdsa::curve::secp256k1::Secp256K1;
use plonky2_ecdsa::gadgets::curve::AffinePointTarget;
use plonky2_ecdsa::gadgets::curve::WitnessPoint;
use plonky2_ecdsa::gadgets::nonnative::NonNativeTarget;
use plonky2_ecdsa::gadgets::nonnative::WitnessNonNative;

use crate::circuit::F;
use crate::curve::point_mul::PrecomputedMulTableTarget;
use crate::curve::point_mul::precompute_mul_table;

#[derive(Clone)]
pub struct TargetInputs {
    server_ephemeral_private_key: NonNativeTarget<Secp256K1Scalar>,
    server_ephemeral_public_key: AffinePointTarget<Secp256K1>,
    pad_public_key: AffinePointTarget<Secp256K1>,
    recovery_code_mul_table: PrecomputedMulTableTarget,
}

impl TargetInputs {
    pub fn new(
        server_ephemeral_private_key: NonNativeTarget<Secp256K1Scalar>,
        server_ephemeral_public_key: AffinePointTarget<Secp256K1>,
        pad_public_key: AffinePointTarget<Secp256K1>,
        recovery_code_mul_table: PrecomputedMulTableTarget,
    ) -> Self {
        Self {
            server_ephemeral_private_key,
            server_ephemeral_public_key,
            pad_public_key,
            recovery_code_mul_table,
        }
    }

    pub fn set_inputs(&self, inputs: &Inputs) -> PartialWitness<F> {
        let mut pw = PartialWitness::new();

        pw.set_non_native_target(
            &self.server_ephemeral_private_key,
            &inputs.server_ephemeral_private_key,
        );

        Self::set_public_key(
            &mut pw,
            &self.server_ephemeral_public_key,
            &inputs.public_inputs.server_ephemeral_public_key,
        );

        Self::set_public_key(
            &mut pw,
            &self.pad_public_key,
            &inputs.public_inputs.pad_public_key,
        );

        Self::set_mul_table(
            &mut pw,
            &self.recovery_code_mul_table,
            &inputs.public_inputs.recovery_code_public_key,
        );

        pw
    }

    fn set_public_key(
        pw: &mut PartialWitness<F>,
        public_key_target: &AffinePointTarget<Secp256K1>,
        public_key: &[Secp256K1Base; 2],
    ) {
        pw.set_affine_point_target(public_key_target, &public_key[0], &public_key[1]);
    }

    fn set_mul_table(
        pw: &mut PartialWitness<F>,
        mul_table: &PrecomputedMulTableTarget,
        public_key: &[Secp256K1Base; 2],
    ) {
        let table_data = precompute_mul_table(AffinePoint {
            x: public_key[0],
            y: public_key[1],
            zero: false,
        });
        for (mul_row, data_row) in mul_table.limbs.iter().zip(table_data) {
            for (mul_element, data_element) in mul_row.iter().zip(data_row) {
                pw.set_affine_point_target(mul_element, &data_element.x, &data_element.y);
            }
        }
    }
}

pub struct Inputs {
    server_ephemeral_private_key: Secp256K1Scalar,
    public_inputs: PublicInputs,
}

impl Inputs {
    pub fn new(
        server_ephemeral_private_key: Secp256K1Scalar,
        server_ephemeral_public_key: [Secp256K1Base; 2],
        recovery_code_public_key: [Secp256K1Base; 2],
        pad_public_key: [Secp256K1Base; 2],
    ) -> Self {
        Self {
            server_ephemeral_private_key,
            public_inputs: PublicInputs::new(
                server_ephemeral_public_key,
                recovery_code_public_key,
                pad_public_key,
            ),
        }
    }
}

pub struct PublicInputs {
    server_ephemeral_public_key: [Secp256K1Base; 2],
    recovery_code_public_key: [Secp256K1Base; 2],
    pad_public_key: [Secp256K1Base; 2],
}

impl PublicInputs {
    pub fn new(
        server_ephemeral_public_key: [Secp256K1Base; 2],
        recovery_code_public_key: [Secp256K1Base; 2],
        pad_public_key: [Secp256K1Base; 2],
    ) -> Self {
        Self {
            server_ephemeral_public_key,
            recovery_code_public_key,
            pad_public_key,
        }
    }

    pub fn prepare_public_inputs(&self) -> Result<Vec<u8>, Error> {
        let mut public_inputs: Vec<u8> = Vec::new();

        Self::prepare_affine_point(&self.server_ephemeral_public_key, &mut public_inputs)?;

        Self::prepare_affine_point(&self.pad_public_key, &mut public_inputs)?;

        Self::prepare_recovery_code_mul_table(&self.recovery_code_public_key, &mut public_inputs)?;

        Ok(public_inputs)
    }

    fn prepare_affine_point(
        public_key: &[Secp256K1Base; 2],
        public_inputs: &mut Vec<u8>,
    ) -> Result<(), Error> {
        for coord in public_key {
            Self::prepare_scalar(*coord, public_inputs)?;
        }

        Ok(())
    }
    fn prepare_scalar(scalar: Secp256K1Base, public_inputs: &mut Vec<u8>) -> Result<(), Error> {
        for i in 0..4 {
            let limb: u64 = scalar.0[i];
            let base: u64 = 1 << 32;
            public_inputs.extend((limb % base).to_le_bytes());
            public_inputs.extend((limb / base).to_le_bytes());
        }

        Ok(())
    }
    fn prepare_recovery_code_mul_table(
        recovery_code_public_key: &[Secp256K1Base; 2],
        public_inputs: &mut Vec<u8>,
    ) -> Result<(), Error> {
        let recovery_code_point = AffinePoint {
            x: recovery_code_public_key[0],
            y: recovery_code_public_key[1],
            zero: false,
        };

        let table_data = precompute_mul_table(recovery_code_point);

        for row in table_data.iter() {
            for entry in row.iter() {
                Self::prepare_scalar(entry.x, public_inputs)?;
                Self::prepare_scalar(entry.y, public_inputs)?;
            }
        }

        Ok(())
    }
}
