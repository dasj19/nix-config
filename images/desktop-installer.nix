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
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

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
