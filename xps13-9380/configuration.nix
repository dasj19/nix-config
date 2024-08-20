{ config, pkgs, lib, gitSecrets, ... }:

let

  # Git secrets.
  daniel-fullname = gitSecrets.danielFullname;

in

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Enable OpenGL support.
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # Boot parameters.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.efiSysMountPoint = "/efi";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;

  # SOPS settings.
  sops.defaultSopsFile = ./secrets/variables.yaml;
  sops.age.generateKey = true;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # SOPS secrets.
  sops.secrets.daniel_password = {};
  sops.secrets.root_password = {};

  # Networking settings.
  networking.hostName = "xps13-9380";
  networking.firewall.allowedTCPPorts = [
    22 # OpenSSH
  ];
  networking.firewall.allowedUDPPorts = [
    69 # TFTPD
  ];
  networking.networkmanager.enable = true;

  # Local time.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.excludePackages = with pkgs; [
    xterm
  ];

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "es";

  # Configure console keymap
  console.keyMap = "es";

  # Adding an extra layout.
  services.xserver.xkb.extraLayouts.esrodk = {
    description = "Spanish +ro/dk diacritics";
    languages = ["dan" "eng" "rum" "spa"];
    symbolsFile = ./esrodk;
  };

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

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Allow updating of password hashes.
  # Consider adopt userborn after it is merged: https://github.com/NixOS/nixpkgs/pull/332719
  #  users.mutableUsers = false;

  # Underpriviledged account.
  users.users.daniel = {
    isNormalUser = true;
    description = daniel-fullname;
    hashedPasswordFile = config.sops.secrets.daniel_password.path;
    extraGroups = [ "networkmanager" "wheel" "docker" "dialout" ];
  };
  users.users.root = {
    hashedPasswordFile = config.sops.secrets.root_password.path;
  };

  environment.systemPackages = with pkgs; [
    # Nix ecosystem.
    nix-search-cli
    nixpkgs-review

    # CLIs.
    bchunk
    bsdiff
    gdb
    git
    iat
    ffmpeg
    libxslt
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
    unrar
    zstd
    kermit
    w3m
    shntool
    tftp-hpa
    smartmontools

    # Encryption.
    age
    git-crypt
    sops

    # GUIs.
    evolution
    cuetools
    firefox
    fontforge-gtk
    gparted
    gnome-tweaks
    brasero
    halloy
    libreoffice-still
    tor-browser-bundle-bin
    wineWowPackages.stable
    winetricks mono freetype fontconfig
    ghidra
    gimp
    vlc
    qbittorrent
    remmina
    poedit

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
    heimdall
    heimdall-gui
    libusb1
    usbutils
    xd
    pkgs.tt
  ];

  # Temp TFTP server.
  services.atftpd.enable = true;
  services.atftpd.root = "/srv/tftp";

  # Virtualisation.
  virtualisation.docker.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable fish as the default shell.
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Fish customizations.
  programs.fish.interactiveShellInit = ''
    # Forcing true colors.
    set -g fish_term24bit 1
    # Empty fish greeting. @TODO: make it a fish option upstream.
    set -g fish_greeting ""
    # Pasting hostname and current date.
    echo "xps13-9380"
    echo (date "+%T - %F")
  '';

  # Cross-shell prompt.
  programs.starship.enable = true;
  # Starship configuration.
  programs.starship.settings = {
    # No new line before the prompt.
    add_newline = false;
    # Module configuration.
    line_break = {
      disabled = true;
    };
    hostname = {
      ssh_only = false;
    };
    localip = {
      ssh_only = false;
      disabled = false;
    };
    sudo = {
      disabled = false;
    };
    status = {
      disabled = false;
      map_symbol = true;
    };
    git_status = {
      disabled = false;
      conflicted = "🏳";
      ahead = "🏎💨";
      behind = "😰";
      diverged = "😵";
      up_to_date = "✓";
      untracked = "🤷";
      stashed = "📦";
      modified = "📝";
      staged = "[++\($count\)](green)";
      renamed = "👅";
      deleted = "🗑";
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts-emoji
    noto-fonts-cjk
    font-awesome
    symbola
    material-icons
  ];

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

  # Nix and Nixpkgs configurations.
  nix.settings.experimental-features = [
    "flakes"
    "nix-command"
  ];
  nixpkgs.config.allowUnfree = true;

  # Check documentation if you want/need to change this.
  system.stateVersion = "22.11";
}
