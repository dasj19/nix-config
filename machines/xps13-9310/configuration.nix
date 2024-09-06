{ config, lib, pkgs, gitSecrets, sopsSecrets, ... }:

let

  # Git secrets.
  localhost-alias1 = gitSecrets.xps139310HostAlias1;

in

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Profiles.
      ./../../profiles/laptop.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Latest kernel. For mic support.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "xps13-9310";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Hardware acceleration for intel based graphics cards.
  environment.variables = {
    VDPAU_DRIVER = lib.mkIf config.hardware.graphics.enable (lib.mkDefault "va_gl");
  };

  hardware.graphics.extraPackages = with pkgs; [
    (if (lib.versionOlder (lib.versions.majorMinor lib.version) "23.11") then vaapiIntel else intel-vaapi-driver)
    libvdpau-va-gl
    intel-media-driver
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [

    # CLI.
    awscli2
    php82Packages.composer
    cypress
    docker
    docker-compose
    git
    goaccess
    jq
    nano
    pciutils
    platformsh
    tree
    wget
    xvfb-run
    yarn

    # Libraries.
    nodejs_20
    php82
    stdenv.cc.cc.lib

    # Cryptography.
    git-crypt
    sops

    # Drivers and firmware.
    intel-gmmlib
    glibc

    # GUI.
    chromium
    drawio
    dbeaver-bin
    #element-desktop
    evolution
    filezilla
    firefox
    firefox-devedition-bin
    gimp
    gnome-tweaks
    google-chrome
    libreoffice-still
    meld
    insomnia
    opera
    tor-browser-bundle-bin
    slack
    vlc
    vscode
    vscodium
    zoom-us

    # Temporary
    xorg.xorgserver
    microsoft-edge
  ];

  virtualisation.docker.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22 # OpenSSH
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  system.activationScripts = {
    bashsh.text =
      ''
        ln -sf /run/current-system/sw/bin/bash /bin/bash
      '';
  };

  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    cypress
  ];

  # Shell settings.
  environment.shells = [ pkgs.bashInteractive pkgs.fish ];
  environment.shellAliases = {
    xvfb = "/run/current-system/sw/bin/xvfb-run";
  };

  networking.hosts = {
    "127.0.0.1" = [ localhost-alias1 ];
  };

  # Initial state. Check the manual before changing the state!
  system.stateVersion = "23.05";

}


