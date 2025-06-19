{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ollama-cuda
    shell-gpt
  ];
  # Enable Ollama Cuda as a systemd service.
  systemd.services.ollama-cuda = {
    enable = true;
    after = [ "network.target" ];
    wantedBy = [ "default.target" ];
    description = "Ollama Cuda server";
    serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.ollama-cuda}/bin/ollama serve";
        Environment = ''HOME=/home/daniel'';
        Restart = "always";
    };
  };
}