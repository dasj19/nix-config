# Development packages.
# @todo: move them in separate devenv configurations

{
  pkgs,
  ...
}:

{

  environment.systemPackages = with pkgs; [
    ddev # tool for php-docker development. # cspell:disable-line
    devenv # control development environments with nix.

    mkcert # creates development environment certificates. # cspell:disable-line
    nodejs # node javascript library.
    php83 # PHP.
    php83Packages.composer # Composer package manager for PHP.
    symfony-cli # The CLI tool for Symfony PHP projects.
  ];

  # Setup a mariadb database.
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

  # Virtualisation.
  virtualisation.docker.enable = true;
  virtualisation.docker.extraPackages = [
    pkgs.docker-buildx # handles building docker remotely # cspell:disable-line
  ];

  # Network bridge between vm guest and host.
  virtualisation.libvirtd.allowedBridges = [ "virbr0" ]; # cspell:disable-line

}
