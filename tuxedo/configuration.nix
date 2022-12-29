{ config, lib, pkgs, ... }:

let

  banner = lib.strings.fileContents "${./motd.txt}";
  # Agenix strings:
  localhost-account-daniel-fullname = lib.strings.fileContents config.age.secrets.localhost-account-daniel-fullname.path;

  # Agenix paths:
  localhost-account-daniel-password = config.age.secrets.localhost-account-daniel-password.path;
  localhost-account-root-password = config.age.secrets.localhost-account-root-password.path;
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Agenix for dealing with secrets.
      "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/modules/age.nix"
    ];

  # Agenix secrets.
  age.secrets.localhost-account-daniel-password.file = secrets/localhost-account-daniel-password.age;
  age.secrets.localhost-account-daniel-fullname.file = secrets/localhost-account-daniel-fullname.age;
  age.secrets.localhost-account-root-password.file = secrets/localhost-account-root-password.age;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Linux kernel - Using a stable (non-lts) kernel.
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_0;
  boot.extraModulePackages = with config.boot.kernelPackages; [ tuxedo-keyboard nvidia_x11 ];
  boot.blacklistedKernelModules = [
    "i2c_nvidia_gpu" # https://www.kernel.org/doc/html/latest/i2c/busses/i2c-nvidia-gpu.html
  ];
  # TODO: Disable because of nonfree license. Then find a solution for HDMI output.
  hardware.nvidia.modesetting.enable = true;

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  networking.hostName = "tuxedo";

  # The base time zone.
  time.timeZone = "Europe/Copenhagen";

  # Networking options.
  networking.useDHCP = false;
  networking.interfaces.enp3s0f1.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  # Internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "es";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "esrodk,es,dk,ro";
  # TODO: Disable because of nonfree license. Then find a solution for HDMI output.
  services.xserver.videoDrivers = [ "nvidia" ];

  # Disable unused xserver packages.
  services.xserver.excludePackages = with pkgs; [
    xterm
  ];

  # Adding an extra layout.
  services.xserver.extraLayouts.esrodk = {
    description = "Spanish +ro/dk diacritics";
    languages = ["spa"];
    symbolsFile = /etc/nixos/esrodk;
  };


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

  # Gnome changes.
  services.xserver.desktopManager.gnome.extraGSettingsOverridePackages = with pkgs; [
    gnome.gnome-terminal
  ];
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
      [org.gnome.Terminal.Legacy.Settings]
      theme-variant='dark'
  '';
  
  # Enable gnome-keyring.
  services.gnome.gnome-keyring.enable = true;
  

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];

  # DESKTOP CUSTOMIZATIONS. #

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

  # Allow immutable users.
  users.mutableUsers = false;

  # Main user.
  users.users.daniel = {
    isNormalUser = true;
    home = "/home/daniel";
    extraGroups = [ "wheel" "docker" "audio" "libvirtd" ];
    description = localhost-account-daniel-fullname;
    passwordFile = localhost-account-daniel-password;
  };

  # The root user.
  users.users.root = {
    passwordFile = localhost-account-root-password;
  };


  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    # Development.
    firefox-devedition-bin
    php
    vscodium #vscode-with-extensions
    arduino
    insomnia
    dbeaver
    nix-review nix-prefetch

    # Drivers and Firmware.
    hplip #hplipWithPlugin
    cups ntfs3g

    # Desktop apps.
    gnome.gnome-tweaks gnome-network-displays freerdp
    gparted evolutionWithPlugins  evolution-ews
    firefox-bin tor-browser-bundle-bin
    qbittorrent ungoogled-chromium meld
    strawberry osdlyrics
    gimp pdfarranger drawio inkscape
    signal-desktop
    vlc lbry
    gcstar
    czkawka
    protonvpn-gui element-desktop
    
    kodi
    #(pkgs.kodi.passthru.withPackages (kodiPkgs: with kodiPkgs; [
    #  a4ksubtitles
    #]))

    #Localization
    poedit aspell aspellDicts.ro gtranslator

    # CLI Utilities.
    lshw wget git cpufrequtils youtube-dl yt-dlp
    ffmpeg dconf shntool flac cuetools
    asciinema tree usbutils nmap
    nix-tree inetutils openssl
    android-tools adb-sync scrcpy
    p7zip nnn debootstrap
    # Agenix secret management.
    (pkgs.callPackage "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/pkgs/agenix.nix" {})

    # Research & Text editing tools.
    libreoffice-fresh

    # Streaming & Recording.
    #obs-studio
    shotcut

    # Virtualization.
    virt-manager docker-compose

    # Games.
    xonotic superTux superTuxKart mars

    # Temporary.
    gnome-multi-writer woeusb
    android-tools
    # Temp proprietary.
  ];

  # Local postgresql server.
  services.postgresql.enable = true;
  services.postgresql.authentication = ''
    host all all 127.0.0.1/32 password
  '';

  # Still enabled because of nvidia firmware.
  nixpkgs.config.allowUnfree = true;

  programs.dconf.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.banner = banner;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22
    3389 # RDP connections
    3333 # LBRY Dameon
    4444 # LBRY Streams
    5278
    5279
    5280
    5567 # LBRY P2P
    9003
    50001 # LBRY Wallet
  ];
  networking.firewall.allowedUDPPorts = [ 22 3389 9003
    5278
    5279
    5280
    4444 # LBRY Streams
  ];

  # Enable fish as the default shell.
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Fish customizations.
  programs.fish.shellInit = ''
    echo "${banner}"
    echo "TUXEDO XA15"
    echo (date "+%T - %F")
  '';
  programs.fish.interactiveShellInit = ''
    # Forcing true colors.
    set -g fish_term24bit 1
    # Empty fish greeting. @TODO: make it a fish option upstream.
    set -g fish_greeting ""
  '';

  environment.shellAliases = {
    # change nixos-rebuild to use my own version of nixpkgs.
    nixos-rebuild = "nixos-rebuild -I nixpkgs=/home/daniel/workspace/projects/nixpkgs --keep-going";
  };

  # Initial version. Consult manual before changing.
  system.stateVersion = "22.05";

}
