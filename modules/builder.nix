{ ... }:

{
  nix.buildMachines = [
    # Requires manual setup of ssh keys.
    {
      hostName = "contabo1";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      maxJobs = 1;
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }
  ];
  nix.distributedBuilds = true;
  # Useful when the builder has a faster internet connection than this host.
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
}