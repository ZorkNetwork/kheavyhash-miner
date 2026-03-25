#[cfg(all(target_arch = "aarch64", not(feature = "no-asm"), not(target_os = "windows"),))]
pub(super) fn f1600(state: &mut [u64; 25]) {
    extern "C" {
        fn KeccakF1600(state: &mut [u64; 25]);
    }
    #[cfg(not(feature = "no-sha3-asm"))]
    extern "C" {
        fn KeccakF1600_cext(state: *mut u64);
    }

    unsafe {
        #[cfg(not(feature = "no-sha3-asm"))]
        if sha3_asm_available() {
            KeccakF1600_cext(state.as_mut_ptr());
            return;
        }
        KeccakF1600(state);
    }
}

#[cfg(all(target_arch = "aarch64", not(feature = "no-asm"), not(feature = "no-sha3-asm"), not(target_os = "windows"),))]
fn sha3_asm_available() -> bool {
    if cfg!(target_feature = "sha3") {
        return true;
    }
    #[cfg(target_os = "macos")]
    {
        return macos_sha3_available();
    }
    #[cfg(not(target_os = "macos"))]
    {
        std::arch::is_aarch64_feature_detected!("sha3")
    }
}

#[cfg(all(
    target_arch = "aarch64",
    not(feature = "no-asm"),
    not(feature = "no-sha3-asm"),
    not(target_os = "windows"),
    target_os = "macos",
))]
fn macos_sha3_available() -> bool {
    use std::sync::OnceLock;

    static CACHE: OnceLock<bool> = OnceLock::new();
    *CACHE.get_or_init(|| unsafe {
        let keys: [&[u8]; 2] = [b"hw.optional.arm.FEAT_SHA3\0", b"hw.optional.armv8_2_sha3\0"];
        for name in keys {
            let mut value: u32 = 0;
            let mut len = std::mem::size_of::<u32>();
            let r = libc::sysctlbyname(
                name.as_ptr().cast::<libc::c_char>(),
                (&mut value as *mut u32).cast::<libc::c_void>(),
                &mut len,
                std::ptr::null_mut(),
                0,
            );
            if r == 0 && value != 0 {
                return true;
            }
        }
        false
    })
}

#[cfg(all(any(target_arch = "x86_64", target_arch = "riscv64"), not(feature = "no-asm"), not(target_os = "windows"),))]
pub(super) fn f1600(state: &mut [u64; 25]) {
    extern "C" {
        fn KeccakF1600(state: &mut [u64; 25]);
    }
    unsafe { KeccakF1600(state) }
}

#[cfg(any(feature = "no-asm", target_os = "windows"))]
pub(super) fn f1600(state: &mut [u64; 25]) {
    keccak::f1600(state);
}

#[cfg(all(
    not(feature = "no-asm"),
    not(target_os = "windows"),
    not(any(target_arch = "x86_64", target_arch = "riscv64", target_arch = "aarch64"))
))]
compile_error!(
    "Unsupported architecture without asm; enable `--features=no-asm` for a portable Keccak implementation."
);
