#[cfg(test)]
mod tests {
    use crate::*;

    const SERVER_EPHEMERAL_PRIVATE_KEY: &str =
        "a5270eb65b67f5b4a0c9946956ea357255512126875ac01e9e6fb48ca143a30f";
    const SERVER_EPHEMERAL_PUBLIC_KEY: &str =
        "0383dade688e5b3c3c1417bf3087657c5411c22b0a4a727ebab45861be308bee8e";
    const RECOVERY_CODE_PUBLIC_KEY: &str =
        "0239243353aeeaf542bcf339bc82a5c0fbd50e7aca9be0c3651509d857373ebc33";
    const SHARED_SECRET_PUBLIC_KEY: &str =
        "02b1f67530fd1b5c2d2019b7f38f022d6e968237806c437c216f961612788c3ede";

    fn str_to_arr<const N: usize>(s: &str) -> [u8; N] {
        hex::decode(s).unwrap().try_into().unwrap()
    }

    fn timed<T, F: FnOnce() -> T>(name: &str, f: F) -> T {
        let before = std::time::Instant::now();
        let result = f();
        let after = std::time::Instant::now();
        eprintln!("{name} took {:?}", after.duration_since(before));
        result
    }

    #[test]
    fn test_prove_verify() {
        let (prover_data, verifier_data) = timed("precompute", precompute);

        let proof = timed("prove", || {
            prove(&prover_data, &ProverInputs {
                ephemeral_private_key: str_to_arr(SERVER_EPHEMERAL_PRIVATE_KEY),
                ephemeral_public_key: str_to_arr(SERVER_EPHEMERAL_PUBLIC_KEY),
                recovery_code_public_key: str_to_arr(RECOVERY_CODE_PUBLIC_KEY),
                shared_public_key: str_to_arr(SHARED_SECRET_PUBLIC_KEY),
            })
            .unwrap()
        });

        timed("verify", || {
            verify(&verifier_data, proof, &VerifierInputs {
                ephemeral_public_key: str_to_arr(SERVER_EPHEMERAL_PUBLIC_KEY),
                recovery_code_public_key: str_to_arr(RECOVERY_CODE_PUBLIC_KEY),
                shared_public_key: str_to_arr(SHARED_SECRET_PUBLIC_KEY),
            })
            .unwrap()
        });
    }

    #[test]
    fn test_comparing_circuits_constants() {
        let verifier1 = precompute().1;
        let verifier2 = precompute().1;

        assert_eq!(verifier1.serialize(), verifier2.serialize());
    }

    #[test]
    #[should_panic]
    fn incorrect_ephemeral_private_key() {
        let (prover_data, _) = precompute();

        prove(&prover_data, &ProverInputs {
            ephemeral_private_key: str_to_arr(
                "a5270eb65b67f5b4a0c9946956ea357255512126875ac01e9e6fb48ca143a30e",
            ),
            ephemeral_public_key: str_to_arr(SERVER_EPHEMERAL_PUBLIC_KEY),
            recovery_code_public_key: str_to_arr(RECOVERY_CODE_PUBLIC_KEY),
            shared_public_key: str_to_arr(SHARED_SECRET_PUBLIC_KEY),
        })
        .unwrap();
    }

    #[test]
    #[should_panic]
    fn incorrect_ephemeral_public_key() {
        let (prover_data, _) = precompute();

        prove(&prover_data, &ProverInputs {
            ephemeral_private_key: str_to_arr(SERVER_EPHEMERAL_PRIVATE_KEY),
            ephemeral_public_key: str_to_arr(
                "0383dade688e5b3c3c1417bf3087657c5411c22b0a4a727ebab45861be308bee8d",
            ),
            recovery_code_public_key: str_to_arr(RECOVERY_CODE_PUBLIC_KEY),
            shared_public_key: str_to_arr(SHARED_SECRET_PUBLIC_KEY),
        })
        .unwrap();
    }

    #[test]
    #[should_panic]
    fn incorrect_recovery_code_public_key() {
        let (prover_data, _) = precompute();

        prove(&prover_data, &ProverInputs {
            ephemeral_private_key: str_to_arr(SERVER_EPHEMERAL_PRIVATE_KEY),
            ephemeral_public_key: str_to_arr(SERVER_EPHEMERAL_PUBLIC_KEY),
            recovery_code_public_key: str_to_arr(
                "0239243353aeeaf542bcf339bc82a5c0fbd50e7aca9be0c3651509d857373ebc32",
            ),
            shared_public_key: str_to_arr(SHARED_SECRET_PUBLIC_KEY),
        })
        .unwrap();
    }

    #[test]
    #[should_panic]
    fn test_incorrect_shared_public_key() {
        let (prover_data, _) = precompute();

        prove(&prover_data, &ProverInputs {
            ephemeral_private_key: str_to_arr(SERVER_EPHEMERAL_PRIVATE_KEY),
            ephemeral_public_key: str_to_arr(SERVER_EPHEMERAL_PUBLIC_KEY),
            recovery_code_public_key: str_to_arr(RECOVERY_CODE_PUBLIC_KEY),
            shared_public_key: str_to_arr(
                "03fbd0baf989330446c4f870aecb018a52c15cb7081f55e2cf5b5c5f8932b07691",
            ),
        })
        .unwrap();
    }
}
