# kHeavyHash-Miner

[![Build Status](https://github.com/ZorkNetwork/kheavyhash-miner/actions/workflows/ci.yaml/badge.svg)](https://github.com/ZorkNetwork/kheavyhash-miner/actions/workflows/ci.yaml)   [![Dependency Status](https://deps.rs/repo/github/ZorkNetwork/kheavyhash-miner/status.svg)](https://deps.rs/repo/github/ZorkNetwork/kheavyhash-miner)

## Installation

### From Git Sources

The plugins are additional packages in the workspace. To compile specific packages:

```sh
git clone git@github.com:ZorkNetwork/kheavyhash-miner.git
cd kheavyhash-miner
cargo build --release -p kheavyhash-miner -p kaspacuda -p kaspaopencl
```

The miner (and plugins) will be in `target/release`. You can replace the last line with:

```sh
cargo build --release --all
```

### From Binaries
The [release page](https://github.com/ZorkNetwork/kheavyhash-miner/releases) includes precompiled binaries for several system types. These include:

| O/S     | Processor       | Features       |
|---------|-----------------|----------------|
| Linux   | Intel/AMD       | GPU default    |
| Linux   | Intel/AMD       | GPU overclock  |
| Windows | Intel/AMD       | GPU default    |
| Windows | Intel/AMD       | GPU overclock  |
| MacOS   | Intel           | CPU Only       |
| MacOS   | Apple Silicon   | CPU Only       |
| Linux   | ARMv8 / aarch64 | CPU Only       |
| Linux   | RISC-V          | CPU Only       |

### Removing Plugins

To remove a plugin, remove the corresponding `dll`/`so` from the miner directory.

* `libkaspacuda.so`, `libkaspacuda.dll`: CUDA support for kHeavyHash-Miner
* `libkaspaopencl.so`, `libkaspaopencl.dll`: OpenCL support for kHeavyHash-Miner

# Usage

## Kaspa
To start mining, you need to run [kaspad](https://github.com/kaspanet/kaspad) and have an address to send the rewards to.
Here is guidance on how to run a full node and how to generate addresses: https://github.com/kaspanet/docs/blob/main/Getting%20Started/Full%20Node%20Installation.md

## Zorkcoin
For Zorkcoin, use a `stratum+tcp://` pool URL with a zorkcoin address following the
`--kaspad-address` (see `--help`).

Building from source requires a **Protocol Buffers compiler** (`protoc`) on `PATH` for gRPC codegen (see `.github/actions/install-protoc` for the version used in CI).

Help (clap 4). **CUDA** options (`--cuda-device`, `--cuda-disable`, `--cuda-workload`, …) are appended when the CUDA plugin loads successfully from the same directory as the binary; if a plugin fails to load you may see a warning but the miner still runs.

```
A CPU/GPU kHeavyHash algorithm miner

Usage: kheavyhash-miner [OPTIONS] --mining-address <MINING_ADDRESS>

Options:
  -d, --debug
          Enable debug logging level
  -a, --mining-address <MINING_ADDRESS>
          The Kaspa address for the miner reward
  -s, --kaspad-address <KASPAD_ADDRESS>
          The IP of the kaspad instance [default: 127.0.0.1]
      --devfund-percent <DEVFUND_PERCENT>
          The percentage of blocks to send to the devfund (minimum 2%) [default: 2]
  -p, --port <PORT>
          Kaspad port [default: Mainnet = 16110, Testnet = 16211]
      --testnet
          Use testnet instead of mainnet [default: false]
  -t, --threads <NUM_THREADS>
          Amount of CPU miner threads to launch [default: 0]
      --mine-when-not-synced
          Mine even when kaspad says it is not synced, only useful when passing `--allow-submit-block-when-not-synced` to kaspad  [default: false]
      --opencl-platform <OPENCL_PLATFORM>
          Which OpenCL platform to use (limited to one per executable)
      --opencl-device <OPENCL_DEVICE>
          Which OpenCL GPUs to use on a specific platform
      --opencl-workload <OPENCL_WORKLOAD>
          Ratio of nonces to GPU possible parrallel run in OpenCL [default: 512]
      --opencl-workload-absolute
          The values given by workload are not ratio, but absolute number of nonces in OpenCL [default: false]
      --opencl-enable
          Enable opencl, and take all devices of the chosen platform
      --opencl-amd-disable
          Disables AMD mining (does not override opencl-enable)
      --opencl-no-amd-binary
          Disable fetching of precompiled AMD kernel (if exists)
      --experimental-amd
          Uses SMID instructions in AMD. Miner will crash if instruction is not supported
      --opencl-nonce-gen <OPENCL_NONCE_GEN>
          Random nonce strategy for OpenCL: xoshiro or lean [default: lean]
  -h, --help
          Print help (see a summary with '-h')
  -V, --version
          Print version
```

To start mining against a local Kaspa node:

`./kheavyhash-miner --mining-address kaspa:XXXXX`

This will run the miner on all available GPU devices when plugins are present.

# Devfund

The devfund is a fund managed by the Kaspa community in order to fund Kaspa development <br>
A miner that wants to mine higher percentage into the dev-fund can pass the following flags: <br>
`--devfund-percent=XX.YY` to mine only XX.YY% of the blocks into the devfund.

**This version automatically sets the devfund donation to the community designated address.
Due to community decision, the minimum amount in the precompiled binaries is 2%**

# Donation Addresses

**Elichai**: `kaspa:qzvqtx5gkvl3tc54up6r8pk5mhuft9rtr0lvn624w9mtv4eqm9rvc9zfdmmpu`

**HauntedCook**: `kaspa:qz4jdyu04hv4hpyy00pl6trzw4gllnhnwy62xattejv2vaj5r0p5quvns058f`
