# ai: system-wide configuration of AI tools.
# contains: CLI tools based on ollama, video enhancing tools and more.

{
  pkgs,
  ...
}:

{

  imports = [
    # Non-free software.
    ./non-free.nix
  ];

  # Non-free AI/Cuda libraries.
  allowedUnfree = [
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
    # Self-hosted web solutions.
    "open-webui"
  ];

  # AI system tools.
  environment.systemPackages = with pkgs; [
    llmfit      # Checks what LLMs run optimally on current hardware.
    shell-gpt   # ChatGPT/Ollama client.
    tgpt        # ChatGPT client with no need for API keys.
    video2x     # video upscaler with cuda support.
  ];

  # Use cuda-powered ollama.
  services.ollama.enable = true;
  services.ollama.user = "ollama";
  services.ollama.package = pkgs.ollama-cuda;
  # Prefer cuda packages from nixpkgs.
  # This triggers rebuilding of massive software packages
  # like GIMP and the like, we avoid it for now.
  #nixpkgs.config.cudaSupport = true;

  # cspell:ignore gguf
  # llama-cpp supports models in the gguf format.
  services.llama-cpp.enable = true;
  services.llama-cpp.modelsDir = "/var/lib/llama-cpp/models/";

  # Enable ChatGPT-like user interface for ollama.
  services.open-webui.enable = true;
  services.open-webui.port = 4141;
}
