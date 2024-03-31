{ config, lib, pkgs, ... }:

let

  # Agenix strings:
  localhost-account-daniel-fullname = lib.strings.fileContents config.age.secrets.localhost-account-daniel-fullname.path;

in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Agenix for dealing with secrets.
      "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/modules/age.nix"
    ];

  # Agenix secrets.
  age.secrets.localhost-account-daniel-fullname.file = secrets/localhost-account-daniel-fullname.age;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Latest kernel. For mic support.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "xps13-9310"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_DK.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Disable unused gnome packages.
  environment.gnome.excludePackages = with pkgs; [
    gnome-photos gnome.geary gnome.gnome-music
    gnome.gnome-weather gnome.gnome-clocks gnome.cheese
    gnome-tour gnome-connections gnome.gnome-logs
    gnome.gnome-maps
  ];

  # Configure keymap in X11
  services.xserver.xkb.layout = "esrodk,es,dk,ro";

  # Configure console keymap
  console.keyMap = "es";

  # Adding an extra layout.
  services.xserver.xkb.extraLayouts.esrodk = {
    description = "Spanish with roda diacritics";
    languages = ["spa"];
    symbolsFile = /etc/nixos/esrodk;
  };

  # Custom user directories.
  # Run "xdg-user-dirs-update --force" after changing theese.
  environment.etc."xdg/user-dirs.defaults".text = ''
    DESKTOP=system/desktop
    DOWNLOAD=downloads
    TEMPLATES=system/templates
    PUBLICSHARE=system/public
    DOCUMENTS=documents
    MUSIC=media/music
    PICTURES=media/photos
    VIDEOS=media/video
  '';

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Underpriviledged user account.
  users.users.daniel = {
    isNormalUser = true;
    description = localhost-account-daniel-fullname;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [ /* no user packages */ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    # Agenix secret management.
    (pkgs.callPackage "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/pkgs/agenix.nix" {})

    # CLI.
    awscli2
    codeium
    docker
    docker-compose
    git
    jq
    nano
    platformsh
    tree

    # GUI.
    chromium
    dbeaver
    element-desktop
    evolution
    filezilla
    firefox
    firefox-devedition-bin
    gimp
    gnome.gnome-tweaks
    google-chrome
    libreoffice-still
    meld
    insomnia
    opera
    tor-browser-bundle-bin
    slack
    vscode
    vscodium
    zoom-us

    # Libraries.
    nodejs_20
    php81
    php81Packages.phpcs
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

  # Enable fish as the default shell.
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Allowed shells.
  environment.shells = [ pkgs.bashInteractive pkgs.fish ];

  system.activationScripts = {
    bashsh.text =
      ''
        ln -sf /run/current-system/sw/bin/bash /bin/bash
      '';
  };


  environment.shellAliases = {
    # change nixos-rebuild to use my own version of nixpkgs.
    nixos-rebuild = "nixos-rebuild -I nixpkgs=/home/daniel/workspace/nixpkgs --log-format bar-with-logs --keep-going";
  };

  # Initial state. Check the manual before changing the state!
  system.stateVersion = "23.05";

}

