//! One-shot RISC-V Vector (RVV) capability detection for Linux.
//! Uses `riscv_hwprobe` when available, else parses `/proc/cpuinfo`.

#[cfg(all(target_arch = "riscv64", target_os = "linux"))]
const SYS_RISCV_HWPROBE: libc::c_long = 258;

#[cfg(all(target_arch = "riscv64", target_os = "linux"))]
const RISCV_HWPROBE_KEY_IMA_EXT_0: i64 = 4;

/// Bit for the V extension in `RISCV_HWPROBE_KEY_IMA_EXT_0` (`RISCV_HWPROBE_IMA_V`).
#[cfg(all(target_arch = "riscv64", target_os = "linux"))]
const RISCV_HWPROBE_IMA_V: u64 = 1 << 2;

#[repr(C)]
#[cfg(all(target_arch = "riscv64", target_os = "linux"))]
struct RiscvHwprobe {
    key: i64,
    value: u64,
}

#[cfg(all(target_arch = "riscv64", target_os = "linux"))]
fn hwprobe_ima_ext0() -> Option<u64> {
    let mut pair = RiscvHwprobe { key: RISCV_HWPROBE_KEY_IMA_EXT_0, value: 0 };
    // long sys_riscv_hwprobe(struct riscv_hwprobe *pairs, size_t pair_count,
    //                        size_t cpu_count, unsigned long *cpus, unsigned int flags);
    let err = unsafe {
        libc::syscall(
            SYS_RISCV_HWPROBE,
            &mut pair as *mut RiscvHwprobe,
            1usize,
            0usize,
            std::ptr::null::<libc::c_ulong>(),
            0u32,
        )
    };
    if err == 0 {
        Some(pair.value)
    } else {
        None
    }
}

#[cfg(all(target_arch = "riscv64", target_os = "linux"))]
fn cpuinfo_has_vector_v() -> bool {
    let Ok(contents) = std::fs::read_to_string("/proc/cpuinfo") else {
        return false;
    };
    for line in contents.lines() {
        let line = line.trim();
        if let Some(rest) = line.strip_prefix("isa") {
            let rest = rest.trim_start_matches(|c: char| c == ':' || c.is_whitespace());
            // e.g. rv64imafdcv — 'v' is the vector extension letter (not part of imafd).
            return rest.contains('v');
        }
    }
    false
}

/// Returns `true` if this Linux riscv64 host reports RVV support.
#[cfg(all(target_arch = "riscv64", target_os = "linux"))]
pub fn linux_riscv_has_rvv() -> bool {
    if let Some(bits) = hwprobe_ima_ext0() {
        return (bits & RISCV_HWPROBE_IMA_V) != 0;
    }
    cpuinfo_has_vector_v()
}

#[cfg(not(all(target_arch = "riscv64", target_os = "linux")))]
#[allow(dead_code)] // Used only on riscv64 Linux from heavy_hash::init_riscv_pow_dispatch.
pub fn linux_riscv_has_rvv() -> bool {
    false
}
