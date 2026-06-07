# rpi4-tv: raspberry pi 4 for managing a tv-tuner.
# scope: server

{
  gitSecrets,
  ...
}:

let
  wifi-ap = gitSecrets.primaryAP;
  wifi-pass = gitSecrets.primaryAPPassword;
in

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix
    # Profile.
    ./../../profiles/server.nix
  ];

  # Use the extlinux boot loader. (NixOS enables GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # Networking.
  networking.hostName = "rpi4-tv";

  # Enable tvheadend.
  #services.tvheadend.enable = true;

  # Wifi connection.
  networking.wireless.enable = true;
  networking.wireless.networks."${wifi-ap}".psk = "${wifi-pass}";

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    9981 # TVHeadEnd HTTP
    9982 # TVHeadEnd HTSP
  ];

  # Check the manual before changing this.
  system.stateVersion = "24.11";

}
