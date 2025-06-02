use std::panic;
use std::slice;

use anyhow::anyhow;
use cosigning_key_validation::Proof;
use cosigning_key_validation::VerifierData;
use cosigning_key_validation::VerifierInputs;

#[repr(C)]
pub struct CharArray {
    data: *const libc::c_char,
    len: u64,
}

unsafe fn c_array_to_vec(arr: CharArray) -> Vec<u8> {
    slice::from_raw_parts(arr.data.cast(), arr.len as usize).to_vec()
}

fn vec_to_dangling_c_arr(vec: &[u8]) -> CharArray {
    let ptr = unsafe { libc::malloc(vec.len()) };
    unsafe {
        libc::memcpy(ptr, vec.as_ptr().cast(), vec.len());
    }
    CharArray {
        data: ptr.cast_const().cast(),
        len: vec.len() as u64,
    }
}

fn to_fixed_size_arr<const N: usize>(v: &[u8]) -> anyhow::Result<[u8; N]> {
    v.try_into()
        .map_err(|_| anyhow!("expected length {}, got {}", N, v.len()))
}

#[cfg(feature = "precomputed_verifier_data")]
fn verifier_data() -> &'static [u8] {
    include_bytes!("bin/verifier_data.bin")
}

#[cfg(not(feature = "precomputed_verifier_data"))]
fn verifier_data() -> &'static [u8] {
    panic!("no verifier data")
}

#[unsafe(no_mangle)]
pub extern "C" fn plonky2_server_key_verify(
    proof: CharArray,
    ephemeral_public_key: CharArray,
    recovery_kit_public_key: CharArray,
    shared_public_key: CharArray,
) -> CharArray {
    // Set an empty panic hook to prevent printing to stderr
    panic::set_hook(Box::new(|_info| {}));

    let res = panic::catch_unwind(|| -> anyhow::Result<()> {
        let proof = unsafe { c_array_to_vec(proof) };
        let ephemeral_public_key = unsafe { c_array_to_vec(ephemeral_public_key) };
        let recovery_kit_public_key = unsafe { c_array_to_vec(recovery_kit_public_key) };
        let shared_public_key = unsafe { c_array_to_vec(shared_public_key) };

        cosigning_key_validation::verify(
            &VerifierData::deserialize(verifier_data())?,
            Proof(proof.to_vec()),
            &VerifierInputs {
                ephemeral_public_key: to_fixed_size_arr(&ephemeral_public_key)?,
                recovery_code_public_key: to_fixed_size_arr(&recovery_kit_public_key)?,
                shared_public_key: to_fixed_size_arr(&shared_public_key)?,
            },
        )?;

        Ok(())
    });

    let output = match res {
        Ok(Ok(())) => "ok".to_string(),
        Ok(Err(e)) => format!("error: {}", e),
        Err(e) => format!("panic: {:?}", e),
    };
    vec_to_dangling_c_arr(output.as_bytes())
}
