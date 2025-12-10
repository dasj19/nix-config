{
  nix.buildMachines = [
    # Requires manual setup of ssh keys.
    # The root user on host needs to be able to connect to the builder, preferably by ssh keys.
    {
      hostName = "hostup1";
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      protocol = "ssh";
      maxJobs = 2;
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      mandatoryFeatures = [ ];
    }
  ];
  nix.distributedBuilds = true;
  # Useful when the builder has a faster internet connection than this host.
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
}
