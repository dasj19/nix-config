# ai: system-wide configuration of AI tools.
# contains: CLI tools based on ollama, video enhancing tools and more.

{ pkgs, config, ... }:

{
  imports = [
    # Non-free software.
    ./non-free.nix
    ./cuda-packages.nix
  ];

  # Non-free AI/CUDA libraries.
  allowedUnfree = config.cuda.allowedPackages ++ [
    "cursor-cli" # AI CLI client.
    # Self-hosted web solutions.
    "open-webui"
  ];

  # AI system tools.
  environment.systemPackages = with pkgs; [
    cursor-cli # AI CLI client.
    llmfit # Checks what LLMs run optimally on current hardware.
    shell-gpt # ChatGPT/Ollama client.
    tgpt # ChatGPT client with no need for API keys.
    video2x # video upscaler with cuda support.
  ];

  # Use cuda-powered ollama.
  services.ollama.enable = true;
  services.ollama.user = "ollama";
  services.ollama.package = pkgs.ollama-cuda;
  # Prefer cuda packages from nixpkgs.
  # This triggers rebuilding of massive software packages
  # like GIMP and the like, we avoid it for now.
  # nixpkgs.config.cudaSupport = true;

  # cspell:ignore gguf
  # llama-cpp supports models in the gguf format.
  services.llama-cpp.enable = true;

  # Enable ChatGPT-like user interface for ollama.
  services.open-webui.enable = true;
  services.open-webui.port = 4141;
}
