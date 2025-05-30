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
    extraGroups = [ "networkmanager" "wheel" "vboxsf" ];
  };
  users.users.caddy = {
    extraGroups = [ "vboxsf" ];
  };

  # System specific software.
  environment.systemPackages = with pkgs; [
    git
    graphviz
    openssl
    python3
    wget
  ];

  # SERVICES:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable and configure the Mariadb service.
  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;
  services.mysql.dataDir = "/var/lib/mysql";
  services.mysql.settings = {
    mysqld = {
      bind-address = "0.0.0.0";
      port = 3336;

      # Development server settings.
      # There are permission issues writing logfiles in /var/log, using /tmp for now.
      collation-server = "utf8_unicode_ci";
      character-set-server = "utf8";
      log-error = "/tmp/mysql_err.log";
      slow_query_log = 1;
      slow_query_log_file = "/tmp/mysql_slow.log";
      long_query_time = 2;
    };
  };


  # Network settings.
  networking.firewall.allowedTCPPorts = [
    22
    443
    1080
  ];
  networking.firewall.allowedUDPPorts = [
    443
  ];

  # Check documentation before changing this.
  system.stateVersion = "25.11";

}
