# ai: system-wide configuration of AI tools.
# contains: CLI tools based on ollama, video enhancing tools and more.

{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    shell-gpt # ChatGPT/Ollama client.
    tgpt # ChatGPT client with no need for API keys.
    video2x # video upscaler with the help of cuda.
  ];

  services.ollama.enable = true;
  services.ollama.user = "ollama";

  # cspell:ignore gguf
  # llama-cpp supports models in the gguf format.
  services.llama-cpp.enable = true;
  services.llama-cpp.modelsDir = "/var/lib/llama-cpp/models/";

  # Enable ChatGPT-like user interface for ollama.
  services.open-webui.enable = true;
  services.open-webui.port = 4141;
}
