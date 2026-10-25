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
  virtualisation.podman.enable = true;
  # Provides the docker command and socket for tools like docker compose.
  virtualisation.podman.dockerCompat = true;
  virtualisation.podman.dockerSocket.enable = true;
  # Lets compose containers resolve each other by name.
  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
}
