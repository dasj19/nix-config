{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    ddev
    devenv

    mkcert
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
  virtualisation.docker.extraPackages = [
    pkgs.docker-buildx
    pkgs.docker-compose
  ];

  virtualisation.libvirtd.allowedBridges = [ "virbr0" ];

}
