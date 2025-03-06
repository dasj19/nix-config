{ pkgs, lib, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Profiles.
    ./../../profiles/laptop.nix
  ];

  config = {
    # Boot parameters.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.efiSysMountPoint = "/efi";
    boot.loader.efi.canTouchEfiVariables = true;

    # tmpfs.
    boot.tmp.useTmpfs = true;

    # Networking settings.
    networking.hostName = "xps13-9380";
    networking.networkmanager.enable = true;

    # Host specific packages.
    environment.systemPackages = with pkgs; [
      # Development.
      dart-sass
      docker-compose
      jekyll
      php83
      php83Packages.composer
      python3
    ];

    # Virtualisation.
    virtualisation.docker.enable = true;
    virtualisation.waydroid.enable = true;

    environment.shellAliases = {
      # Provide sass-embedded from nixos.
      sass-embedded = "${pkgs.dart-sass}/bin/sass --embeded";
      dart = "${pkgs.dart-sass}/bin/dart-sass";
    };

    # Needed by jekyll project. @TODO: groom.
    # https://discourse.nixos.org/t/making-lib64-ld-linux-x86-64-so-2-available/19679
    system.activationScripts.ldso = lib.stringAfter [ "usrbinenv" ] ''
      mkdir -m 0755 -p /lib64
      ln -sfn ${pkgs.glibc.out}/lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2.tmp
      mv -f /lib64/ld-linux-x86-64.so.2.tmp /lib64/ld-linux-x86-64.so.2 # atomically replace
    '';

    # Check documentation if you want/need to change this.
    system.stateVersion = "22.11";
  };
}
