{ lib, pkgs, ...}:
{
  imports = [
    ./../modules/aliases.nix
    ./../modules/fish.nix
    ./../modules/folders.nix
    ./../modules/keyboard.nix
    ./../modules/locale.nix
    ./../modules/nix.nix
    ./../modules/starship.nix
    ./../modules/users.nix
  ];

  config = {
    # Preferred cross-system Linux kernel - a LTS kernel. 6.12 is good until December 2026.
    # Check if kernel was updated: ls -l /run/{booted,current}-system/kernel*
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_12;

    # Enable fwupd - Firmware updater.
    services.fwupd.enable = lib.mkDefault true;

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;
    services.openssh.settings.PubkeyAuthentication = true;

    # Limit the space occupied by logs.
    services.journald.extraConfig = ''
      SystemMaxUse=200M
    '';

    # Log rotation.
    services.logrotate.enable = true;
    services.logrotate.settings.header = {
      compress = true;
    };


    # Base packages are a must for every machine.
    # These should be CLI-only packages.
    environment.systemPackages = with pkgs; [
      # CLI.
      aria2
      bat
      colordiff
      cloc
      dig
      dmidecode
      dust
      eza
      fd
      gh
      git
      hexyl
      htop
      jq
      litecli
      lf
      lolcat
      lsof
      lshw
      legit
      ncdu
      nmap
      pandoc
      pciutils
      procs
      pstree
      ripgrep-all
      screen
      smartmontools
      tldr
      tmux
      tree
      usbutils
      unzip
      wget

      # Drivers and Firmware.
      ntfs3g

      # Encryption.
      age
      git-crypt
      sops
    ];
  };
}
