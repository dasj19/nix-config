{
  lib,
  ...
}:

{
  imports = [
    # Profile.
    ./../../profiles/server.nix
    # Include the results of the hardware scan.
    ./hardware.nix
  ];

  networking.hostName = "hostup1";

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Machine's time zone.
  time.timeZone = lib.mkForce "Europe/Stockholm";

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
