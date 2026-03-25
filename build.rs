use std::env;
use time::{format_description, OffsetDateTime};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let format = format_description::parse("[year repr:last_two][month][day][hour][minute]")?;
    let dt = OffsetDateTime::now_utc().format(&format)?;
    println!("cargo:rustc-env=PACKAGE_COMPILE_TIME={}", dt);

    println!("cargo:rerun-if-changed=proto");
    println!("cargo:rerun-if-changed=src/keccakf1600_x86-64.s");
    println!("cargo:rerun-if-changed=src/keccakf1600_riscv64.S");
    println!("cargo:rerun-if-changed=src/keccakf1600_armv8.S");
    println!("cargo:rerun-if-changed=src/keccakf1600_armv8-osx.S");
    tonic_prost_build::configure()
        .build_server(false)
        // .type_attribute(".", "#[derive(Debug)]")
        .compile_protos(
            &["proto/rpc.proto", "proto/p2p.proto", "proto/messages.proto"],
            &["proto"],
        )?;
    let target_arch = env::var("CARGO_CFG_TARGET_ARCH").unwrap();
    let target_os = env::var("CARGO_CFG_TARGET_OS").unwrap();
    if target_arch == "x86_64" && target_os != "windows" && target_os != "macos" {
        cc::Build::new().flag("-c").file("src/keccakf1600_x86-64.s").compile("libkeccak.a");
    }
    if target_arch == "x86_64" && target_os == "macos" {
        cc::Build::new().flag("-c").file("src/keccakf1600_x86-64-osx.s").compile("libkeccak.a");
    }
    if target_arch == "riscv64" && target_os == "linux" {
        cc::Build::new().flag("-c").file("src/keccakf1600_riscv64.S").compile("libkeccak.a");
    }
    if target_arch == "aarch64" && target_os == "linux" {
        cc::Build::new().flag("-c").file("src/keccakf1600_armv8.S").compile("libkeccak.a");
    }
    if target_arch == "aarch64" && target_os == "macos" {
        // When cross-compiling to macOS from Linux/Windows, the default `cc` is often GCC.
        // cc-rs then passes `-arch arm64`, which GCC does not understand. Apple/Darwin targets
        // must use Clang so cc-rs emits `--target=arm64-apple-macosx` instead (see cc-rs
        // `apple_flags` / Clang `--target` path). Native macOS builds keep the default `cc`
        // (typically Apple Clang).
        let host = env::var("HOST").unwrap_or_default();
        let mut build = cc::Build::new();
        build.flag("-c").file("src/keccakf1600_armv8-osx.S");
        if !host.contains("darwin") {
            build.compiler("clang");
        }
        build.compile("libkeccak.a");
    }
    Ok(())
}
