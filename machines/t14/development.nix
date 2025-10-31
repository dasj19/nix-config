{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    devenv
    docker-compose
    nodejs_24
    php82
    php82Packages.composer
    symfony-cli
  ];

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

  # Virtualisation.
  virtualisation.docker.enable = true;

}