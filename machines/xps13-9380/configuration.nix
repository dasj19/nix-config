{ config, pkgs, lib, gitSecrets, sopsSecrets, nixos-artwork, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Modules.
    ./../../modules/audio.nix
    ./../../modules/fish.nix
    ./../../modules/gnome.nix
    ./../../modules/keyboard.nix
    ./../../modules/locale.nix
    ./../../modules/starship.nix
    ./../../modules/stylix.nix
    ./../../modules/users.nix
  ];

  # Enable OpenGL support.
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # Boot parameters.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.efiSysMountPoint = "/efi";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;

  # tmpfs.
  boot.tmp.useTmpfs = true;

  # Firmware update manager. Run 'sudo fwupdmgr refresh' & 'sudo fwupdmgr update' to trigger updates.
  services.fwupd.enable = true;

  # Networking settings.
  networking.hostName = "xps13-9380";
  networking.firewall.allowedTCPPorts = [
    22 # OpenSSH
  ];
  networking.firewall.allowedUDPPorts = [
    69 # TFTPD
    5353 # Avahi
  ];
  networking.networkmanager.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.excludePackages = with pkgs; [
    xterm
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    # Nix ecosystem.
    nix-search-cli
    nixpkgs-review

    # CLIs.
    bchunk
    bsdiff
    eza
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
    dconf

    # Encryption.
    age
    git-crypt
    sops

    # GUIs.
    dconf-editor
    evolution
    cuetools
    firefox
    fontforge-gtk
    gparted
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

  # mDNS server.
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  services.avahi.nssmdns6 = true;

  # Virtualisation.
  virtualisation.docker.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # DESKTOP CUSTOMIZATIONS. #

  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    noto-fonts-emoji
    noto-fonts-cjk
    font-awesome
    fira-code-nerdfont
    symbola
    material-icons
  ];

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

  environment.shellAliases = {
    # Provide sass-embedded from nixos.
    sass-embedded = "${pkgs.dart-sass}/bin/sass --embeded";
    dart = "${pkgs.dart-sass}/bin/dart-sass";
    # Eza for well-known ls aliases, we still keep vanilla ls.
    ll = "eza -lh --icons --grid --group-directories-first";
    la = "eza -lah --icons --grid --group-directories-first";
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
  nix.settings.auto-optimise-store = true;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 10d";

  nixpkgs.config.allowUnfree = true;

  # Check documentation if you want/need to change this.
  system.stateVersion = "22.11";
}
