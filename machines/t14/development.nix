{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    devenv
    docker-compose
    nodejs_24
    php83
    php83Packages.composer
    symfony-cli
  ];

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

  # Virtualisation.
  virtualisation.docker.enable = true;

}
