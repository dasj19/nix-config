{
  config,
  gitSecrets,
  lib,
  pkgs,
  sopsSecrets,
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

  # System-wide packages.
  environment.systemPackages = with pkgs; [

  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes"; # @TODO: remove.

  # Enable tvheadend.
  #services.tvheadend.enable = true;

  # Wifi connection.
  networking.wireless.enable = true;
  networking.wireless.networks."${wifi-ap}".psk = "${wifi-pass}";

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22 # OpenSSH
    9981 # TVHeadEnd HTTP
    9982 # TVHeadEnd HTSP
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # Check the manaul before changing this.
  system.stateVersion = "24.11";

}
