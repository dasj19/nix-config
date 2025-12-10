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

  # hostup1 has 4 cores.
  # Build four jobs at a time using maximum of 1 cores per job.
  nix.settings.max-jobs = 4;
  nix.settings.cores = 1;

  nix.settings.trusted-users = [
    "daniel"
  ];

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
