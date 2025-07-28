{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # gpt4all-cuda    # Open GPT client with CUDA support.
    ollama          # Ollama server without CUDA support.
    shell-gpt       # ChatGPT/Ollama client.
    tgpt            # ChatGPT client with no need for API keys.
    video2x         # video upscaler with the help of cuda.
  ];
  # Enable Ollama Cuda-less as a systemd service.
  systemd.services.ollama-cpu = {
    enable = true;
    after = [ "network.target" ];
    wantedBy = [ "default.target" ];
    description = "Ollama Cuda-less server";
    serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.ollama}/bin/ollama serve";
        Environment = ''HOME=/home/daniel'';
        Restart = "always";
    };
  };
  # Enable ChatGPT-like user interface.
  services.open-webui.enable = true;
  services.open-webui.port = 4141;
}