{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
      ./hardware-configuration.nix
    # Include local webserver configuration.
      ./webserver.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "devbox";

  # Enable networking
  networking.networkmanager.enable = true;

  # Local time zone.
  time.timeZone = "Europe/Copenhagen";

  # Internationalisation.
  i18n.defaultLocale = "en_DK.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  # Keymap in X11.
  services.xserver.xkb = {
    layout = "es";
    variant = "";
  };

  # Console keymap.
  console.keyMap = "es";

  # Users.
  users.users.daniel = {
    isNormalUser = true;
    description = "Daniel";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # System specific software.
  environment.systemPackages = with pkgs; [
    git
    openssl
    wget
  ];

  # SERVICES:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Network settings.
  networking.firewall.allowedTCPPorts = [
    22
    443
  ];
  networking.firewall.allowedUDPPorts = [
    443
  ];

  # Check documentation before changing this.
  system.stateVersion = "25.11";

}
