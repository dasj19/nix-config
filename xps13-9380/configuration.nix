{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Agenix via fetchTarball
      "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/master.tar.gz"}/modules/age.nix"
    ];

  # Temp TFTP server.
  services.atftpd.enable = true;
  services.atftpd.root = "/srv/tftp";

  # Agenix secrets.
  age.secrets.daniel-fullname.file = /etc/nixos/secrets/daniel-fullname.age;
  age.secrets.daniel-password.file = /etc/nixos/secrets/daniel-password.age;
  age.secrets.root-password.file = /etc/nixos/secrets/root-password.age;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "xps13-9380";

  # Enable networking via network manager.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.excludePackages = with pkgs; [
    xterm
  ];

  # Enable LxQt lightweight DE.
  services.xserver.desktopManager.lxqt.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Exclude unnecessary GNOME programs.
  environment.gnome.excludePackages = with pkgs; [
    gnome-photos
    geary
    gnome.gnome-music
    gnome.gnome-weather
    gnome.gnome-clocks
    cheese
    gnome-tour
    gnome-connections
    gnome.gnome-logs
    gnome.gnome-maps
  ];

  # Configure keymap in X11
  services.xserver.xkb.layout = "es";

  # Adding an extra layout.
  services.xserver.xkb.extraLayouts.esrodk = {
    description = "Spanish +ro/dk diacritics";
    languages = ["dan" "eng" "rum" "spa"];
    symbolsFile = /etc/nixos/esrodk;
  };

  # Configure console keymap
  console.keyMap = "es";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Allow updating of password hashes.
  users.mutableUsers = false;
  # Unpriviledged user account with a secret description.
  users.users.daniel = {
    isNormalUser = true;
    description = lib.strings.fileContents config.age.secrets.daniel-fullname.path;
    hashedPasswordFile = config.age.secrets.daniel-password.path;
    extraGroups = [ "networkmanager" "wheel" "docker" "dialout"];
  };
  users.users.root = {
    hashedPasswordFile = config.age.secrets.root-password.path;
  };

  environment.systemPackages = with pkgs; [
    # CLIs.
    (pkgs.callPackage "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/pkgs/agenix.nix" {})
    bchunk
    bsdiff
    gdb
    git
    libxslt
    nixpkgs-review
    nmap
    procmail
    screen
    busybox
    tree
    uudeview
    wget
    xar
    yt-dlp
    zip
    zstd
    kermit
    w3m
    tftp-hpa

    # GUIs.
    evolution
    firefox
    fontforge-gtk
    gparted
    gnome-tweaks

    libreoffice-still
    tor-browser-bundle-bin
    wineWowPackages.stable
    winetricks mono freetype fontconfig
    ghidra
    gimp
    vlc
    qbittorrent
    remmina
    # Electron apps.
    element-desktop
    protonvpn-gui
    signal-desktop
    ungoogled-chromium
    discord

    # Development.
    dart-sass
    docker-compose
    filezilla
    insomnia
    jekyll
    meld
    php83
    php83Packages.composer
    python3
    vscodium

    # Tempporary.
    discord
    #heimdall heimdall-gui
    libusb1
    usbutils
    xd
    pkgs.tt
  ];

  # Enable OpenGL support.
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # Virtualisation.
  virtualisation.docker.enable = true;
  virtualisation.waydroid.enable = true;
  virtualisation.libvirtd.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22 # OpenSSH
  ];
  networking.firewall.allowedUDPPorts = [
    69 # TFTPD
  ];

 # Enable fish as the default shell.
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Fish customizations.
  programs.fish.shellInit = ''
    echo "xps13-9380"
    echo (date "+%T - %F")
  '';
  programs.fish.interactiveShellInit = ''
    # Forcing true colors.
    set -g fish_term24bit 1
    # Empty fish greeting. @TODO: make it a fish option upstream.
    set -g fish_greeting ""
  '';

 nixpkgs.config.allowUnfree = true;

  environment.shellAliases = {
    # change nixos-rebuild to use my own version of nixpkgs.
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
}
