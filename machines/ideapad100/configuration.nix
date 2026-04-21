{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix
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

  #environment.systemPackages = with pkgs; [
  #];

  # SERVICES:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable immich.
  services.immich.enable = true;
  services.immich.port = 2283;
  services.immich.host = "0.0.0.0";
  services.immich.openFirewall = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  system.stateVersion = "26.05";

}
