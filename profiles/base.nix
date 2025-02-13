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
    ./../modules/stylix.nix
    ./../modules/users.nix
  ];

  config = {
    # Preferred cross-system Linux kernel - a LTS kernel. 6.6 is good until December 2026.
    # Check if kernel was updated: ls -l /run/{booted,current}-system/kernel*
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;

    # Enable fwupd - Firmware updater.
    services.fwupd.enable = lib.mkDefault true;

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;
    services.openssh.settings.PubkeyAuthentication = true;

    # Base packages are a must for every machine.
    # These should be CLI-only packages.
    environment.systemPackages = with pkgs; [
      # CLI.
      bat
      eza
      git
      jq
      lf
      lsof
      lshw
      legit
      ncdu
      nmap
      pciutils
      screen
      smartmontools
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
