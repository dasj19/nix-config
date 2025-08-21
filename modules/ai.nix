{ config, lib, pkgs, ... }:

{
  imports = [
    # Modules.
    ./non-free.nix
  ];

  # Custom options.
  options.my.modules.ai = {
    cudaSupport = lib.mkEnableOption "Enable or disable cuda support for the ai module";
  };

  config = {
    environment.systemPackages = with pkgs; [
      # Packages for both cuda and non-cuda systems.
      shell-gpt       # ChatGPT/Ollama client.
      tgpt            # ChatGPT client with no need for API keys.
      video2x         # video upscaler with the help of cuda.
    ] ++ (if config.my.modules.ai.cudaSupport then [
      # Packages for cuda-only systems.
      ollama-cuda     # Ollama server with CUDA support.
    ] else [
      # Packages for cuda-less systems.
      ollama          # Ollama server without CUDA support.
    ]);

    allowedUnfree = [
      # Allowed non-free dependencies of the AI module.
    ] ++ (if config.my.modules.ai.cudaSupport then [
      # Allowed non-free cuda dependencies of the AI module.
      "cuda_cudart"
      "cuda_cccl"
      "cuda_nvcc"
      "libcublas"
    ] else [
      # Allowed non-free cuda-less dependencies of the AI module.
      # Ollama dependencies.
    ]);

    # Enable local Ollama server as a systemd service.
    systemd.services.ollama-local = {
      enable = true;
      after = [ "network.target" ];
      wantedBy = [ "default.target" ];
      description = "Ollama local server";
      serviceConfig = {
          Type = "simple";
          ExecStart = "${if config.my.modules.ai.cudaSupport then pkgs.ollama-cuda else pkgs.ollama}/bin/ollama serve";
          Environment = ''HOME=/home/daniel'';
          Restart = "always";
      };
    };
    # Enable ChatGPT-like user interface.
    services.open-webui.enable = true;
    services.open-webui.port = 4141;
  };
}