{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./caddy.nix
    # Profile.
    ./../../profiles/server.nix
    # Modules.
    ./../../modules/builder.nix
  ];

  boot.loader.grub.devices = [ "/dev/sda" ];

  networking.hostName = "ideapad100";

  networking.networkmanager.enable = true;

  # Server's time zone.
  time.timeZone = "Europe/Copenhagen";

  environment.systemPackages = with pkgs; [
    php85
    php85Packages.composer
    nodejs_25
    nssTools # caddy needs to mange its own certificate.
  ];


  # SERVICES:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable immich.
  services.immich.enable = true;
  services.immich.port = 2283;
  services.immich.host = "0.0.0.0";
  services.immich.openFirewall = true;

  # Enable mariadb.
  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;

  # Control the laptop lidswitch behavior.
  services.logind.settings.Login.HandleLidSwitch = "ignore";
  services.logind.settings.Login.HandleLidSwitchDocked = "ignore";

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    8001 # genealogy
  ];
  networking.firewall.allowedUDPPorts = [
    8001 # genealogy
  ];

  system.stateVersion = "26.05";

}
