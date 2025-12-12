{ pkgs, ... }:

{
  imports = [
    # Hardware config.
    ./hardware.nix
    # Local webserver configuration.
    ./webserver.nix
    # Profiles.
    ../../profiles/server.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "devbox";

  # Enable networking
  networking.networkmanager.enable = true;

  # Users.
  users.users.daniel.extraGroups = [ "vboxsf" ];
  users.users.caddy.extraGroups = [ "vboxsf" ];

  # System specific software.
  environment.systemPackages = with pkgs; [
    graphviz
    openssl
    python3
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
      # There are permission issues writing log files in /var/log, using /tmp for now.
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
