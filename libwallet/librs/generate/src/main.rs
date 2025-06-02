use std::fs;

use cosigning_key_validation::prove;
use cosigning_key_validation::ProverInputs;

fn str_to_arr<const N: usize>(s: &str) -> [u8; N] {
    hex::decode(s).unwrap().try_into().unwrap()
}

const SERVER_EPHEMERAL_PRIVATE_KEY: &str =
    "a5270eb65b67f5b4a0c9946956ea357255512126875ac01e9e6fb48ca143a30f";
const SERVER_EPHEMERAL_PUBLIC_KEY: &str =
    "0383dade688e5b3c3c1417bf3087657c5411c22b0a4a727ebab45861be308bee8e";
const RECOVERY_CODE_PUBLIC_KEY: &str =
    "0239243353aeeaf542bcf339bc82a5c0fbd50e7aca9be0c3651509d857373ebc33";
const SHARED_SECRET_PUBLIC_KEY: &str =
    "02b1f67530fd1b5c2d2019b7f38f022d6e968237806c437c216f961612788c3ede";

fn main() {
    let (prover_data, verifier_data) = cosigning_key_validation::precompute();

    let proof = prove(
        &prover_data,
        &ProverInputs {
            ephemeral_private_key: str_to_arr(SERVER_EPHEMERAL_PRIVATE_KEY),
            ephemeral_public_key: str_to_arr(SERVER_EPHEMERAL_PUBLIC_KEY),
            recovery_code_public_key: str_to_arr(RECOVERY_CODE_PUBLIC_KEY),
            shared_public_key: str_to_arr(SHARED_SECRET_PUBLIC_KEY),
        },
    )
    .unwrap();
    fs::write("test_proof.bin", proof.0).unwrap();

    fs::write(
        "bindings/src/bin/verifier_data.bin",
        verifier_data.serialize(),
    )
    .unwrap();
}
