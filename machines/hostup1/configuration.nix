{
  lib,
  pkgs,
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
  nix.settings.max-jobs = lib.mkForce 4;
  nix.settings.cores = lib.mkForce 1;

  # Github runner to build the nix-config repo/project.
  services.github-runners."nix-config-runner" = {
    enable = true;
    name = "nix-config-runner";
    tokenFile = "/etc/nixos/nix-config-runner.token";
    url = "https://github.com/dasj19/nix-config";
    extraPackages = with pkgs; [
      git-crypt
      openssh
    ];
  };

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
