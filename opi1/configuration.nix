{ pkgs, ... }:

let
  variables = import ./secrets/variables.nix;
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://cache.armv7l.xyz/?trusted=1"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "cache.armv7l.xyz-1:kBY/eGnBAYiqYfg0fy0inWhshUo+pGFM3Pj7kIkmlBk="
  ];

  networking.hostName = "opi1";

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Internationalisation properties.
  #i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "es";
  #};

  # Tor options.
  services.tor.enable = true;
  services.tor.relay.enable = true;
  services.tor.relay.role = "relay";
  services.tor.settings = {
    Address = "${variables.publicIP}";
    ContactInfo = "tor@${variables.primaryDomain}";
    Nickname = "torGnuStyle";
    ORPort = 9001;
    ControlPort = 9051;
    BandWidthRate = "10 MBytes";
  };

  # System-wide packages.
  environment.systemPackages = with pkgs; [
    iftop # monitors network traffic.
    nyx # monitors tor traffic.
    wget # cli general purpose downloader.
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22   # SSH.
    9001 # Tor OR Port.
    9051 # Tor Control Port.
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # Enable fish as the default shell.
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix).
  system.copySystemConfiguration = true;

  # Initial version. Consult manual before changing.
  system.stateVersion = "24.05";

}

