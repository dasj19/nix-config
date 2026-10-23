# development: web development stack shared by the laptops.
# scope: laptops
#
# The PHP version and its extensions are chosen per machine.
# @todo: move them in separate devenv configurations

{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    nodejs # node javascript library.
    pre-commit # Git commit hook.
    symfony-cli # The CLI tool for Symfony PHP projects.
  ];

  # Setup a mariadb database.
  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;

  # Containers.
  virtualisation.docker.enable = true;
}
