# desktop-installer: live ISO based on the NixOS graphical installer with GNOME.
# scope: image
#
# Notes:
#  - build it with: nix build .#desktop-installer, the image lands in result/iso/desktop-installer.iso.
#  - no profile is imported, the laptop profile needs sops secrets and machine hardware.
#  - the installer module brings the generic hardware support, no detection is needed.
#

{
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-gnome.nix"
    # Modules shared with the machines, the ones needing sops secrets are left out.
    ./../modules/fastfetch.nix
    ./../modules/fish.nix
    ./../modules/keyboard.nix
    ./../modules/locale.nix
    ./../modules/nix.nix
    ./../modules/starship.nix
    ./../modules/stylix.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  # The installer's own user, the shared modules add their groups and nix trust to it.
  users.primaryUser = "nixos";

  # The ISO has no ssh key for the remote builder set up in modules/nix.nix.
  nix.distributedBuilds = lib.mkForce false;

  # The ISO builder names the file from image.baseName, image.fileName is ignored.
  image.baseName = lib.mkForce "desktop-installer";

  networking.hostName = "desktop-installer";

  environment.systemPackages = with pkgs; [
    git
    git-crypt
    sops
  ];

  # A live system is rebuilt from scratch every time, so it follows the nixpkgs release.
  system.stateVersion = lib.trivial.release;
}
