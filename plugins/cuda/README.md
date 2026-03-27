# Cuda support for kHeavyHash-Miner

## Building

The plugin is a shared library file that resides in the same library as the miner.
You can build the library by running

```sh
cargo build -p kaspacuda
```

This version includes precompiled PTX files. For `sm_61`, `sm_75`, and `sm_86` there are two artifacts:

- `kaspa-cuda-sm{61,75,86}-1281.ptx` — built with CUDA 12.8.x (PTX ISA 8.7), preferred when the driver JIT supports it.
- `kaspa-cuda-sm{61,75,86}.ptx` — older-toolchain PTX kept for broader driver JIT compatibility as a runtime fallback.

To regenerate the CUDA 12.8.x PTX outputs, clone the project:

```sh
git clone https://github.com/ZorkNetwork/kheavyhash-miner.git
cd kheavyhash-miner
/usr/local/cuda-12.8/bin/nvcc plugins/cuda/kaspa-cuda-native/src/kaspa-cuda.cu -std=c++11 -O3 --restrict --ptx --gpu-architecture=compute_61 --gpu-code=sm_61 -o plugins/cuda/resources/kaspa-cuda-sm61-1281.ptx -Xptxas -O3 -Xcompiler -O3 --allow-unsupported-compiler
/usr/local/cuda-12.8/bin/nvcc plugins/cuda/kaspa-cuda-native/src/kaspa-cuda.cu -std=c++11 -O3 --restrict --ptx --gpu-architecture=compute_75 --gpu-code=sm_75 -o plugins/cuda/resources/kaspa-cuda-sm75-1281.ptx -Xptxas -O3 -Xcompiler -O3 --allow-unsupported-compiler
/usr/local/cuda-12.8/bin/nvcc plugins/cuda/kaspa-cuda-native/src/kaspa-cuda.cu -std=c++11 -O3 --restrict --ptx --gpu-architecture=compute_86 --gpu-code=sm_86 -o plugins/cuda/resources/kaspa-cuda-sm86-1281.ptx -Xptxas -O3 -Xcompiler -O3 --allow-unsupported-compiler
/usr/local/cuda-12.8/bin/nvcc plugins/cuda/kaspa-cuda-native/src/kaspa-cuda.cu -std=c++11 -O3 --restrict --ptx --gpu-architecture=compute_89 --gpu-code=sm_89 -o plugins/cuda/resources/kaspa-cuda-sm89.ptx -Xptxas -O3 -Xcompiler -O3 --allow-unsupported-compiler
/usr/local/cuda-12.8/bin/nvcc plugins/cuda/kaspa-cuda-native/src/kaspa-cuda.cu -std=c++11 -O3 --restrict --ptx --gpu-architecture=compute_90 --gpu-code=sm_90 -o plugins/cuda/resources/kaspa-cuda-sm90.ptx -Xptxas -O3 -Xcompiler -O3 --allow-unsupported-compiler
/usr/local/cuda-12.8/bin/nvcc plugins/cuda/kaspa-cuda-native/src/kaspa-cuda.cu -std=c++11 -O3 --restrict --ptx --gpu-architecture=compute_100 --gpu-code=sm_100 -o plugins/cuda/resources/kaspa-cuda-sm100.ptx -Xptxas -O3 -Xcompiler -O3 --allow-unsupported-compiler

# Legacy compatibility exceptions:
# CUDA 12.8 cannot regenerate sm_20/sm_30. Existing kaspa-cuda-sm20.ptx and
# kaspa-cuda-sm30.ptx are retained as historical compatibility artifacts.

cargo build --release
```

## Overclock mode

In the overclock build flavor, CUDA OC operations are enabled by default when OC flags are provided.

- If NVML cannot initialize while OC flags are provided, the miner exits gracefully.
- Add `--overclock-fallback` to continue mining on the non-overclock CUDA path when NVML init fails.
