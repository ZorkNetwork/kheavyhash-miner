#[cfg(all(
    any(target_arch = "x86_64", target_arch = "riscv64"),
    not(feature = "no-asm"),
    not(target_os = "windows")
))]
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
    not(any(target_arch = "x86_64", target_arch = "riscv64"))
))]
compile_error!("Unsupported architecture without asm; enable `--features=no-asm` for a portable Keccak implementation.");
