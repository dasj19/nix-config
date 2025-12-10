{ config, lib, pkgs, ... }:

{
  imports = [
    # Profile.
    ./../../profiles/server.nix
    # Include the results of the hardware scan.
    ./hardware.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "hostup1";

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Machine's time zone.
  time.timeZone = lib.mkForce "Europe/Stockholm";

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22 # OpenSSH.
  ];
  networking.firewall.allowedUDPPorts = [ ];

  # Consult the manual before changing the state version.
  system.stateVersion = "25.11";

}

