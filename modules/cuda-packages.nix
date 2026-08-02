# cuda-packages: list of non-free NVIDIA CUDA packages needed by AI tools.
# Declared as a module option so other modules can reference
# `config.cuda.allowedPackages` without needing specialArgs.

{ config, lib, ... }:

{
  options.cuda.allowedPackages = lib.mkOption {
    type = with lib.types; listOf str;
    default = [
      "cuda_cccl"
      "cuda_cudart"
      "cuda_cuobjdump"
      "cuda_cupti"
      "cuda_cuxxfilt"
      "cuda_gdb"
      "cuda-merged"
      "cuda_nvcc"
      "cuda_nvdisasm"
      "cuda_nvml_dev"
      "cuda_nvprune"
      "cuda_nvrtc"
      "cuda_nvtx"
      "cuda_profiler_api"
      "cuda_sanitizer_api"
      "cudnn" # cspell:disable-line
      "libcublas"
      "libcurand"
      "libcusparse"
      "libnvjitlink"
      "libcufile" # cspell:disable-line
      "libcufft"
      "libcusolver"
      "libcusparse_lt"
      "libnpp"
    ];
    description = ''
      List of non-free NVIDIA CUDA packages to allow via the
      allowUnfree predicate.
    '';
  };
}
