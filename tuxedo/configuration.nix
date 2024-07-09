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

  # Nix build settings. @TODO: move to a server machine like contbao1.
  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://cache.armv7l.xyz/?trusted=1"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "cache.armv7l.xyz-1:kBY/eGnBAYiqYfg0fy0inWhshUo+pGFM3Pj7kIkmlBk="
  ];

  # Emulate arm.
  boot.binfmt.emulatedSystems = [ "armv7l-linux" ];

  nix.distributedBuilds = true;
  # Useful when the builder has a faster internet connection than yours
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
  nix.settings.trusted-users = [ "root" "daniel" ];


  # Agenix secrets.
  age.secrets.localhost-account-daniel-password.file = secrets/localhost-account-daniel-password.age;
  age.secrets.localhost-account-daniel-fullname.file = secrets/localhost-account-daniel-fullname.age;
  age.secrets.localhost-account-root-password.file = secrets/localhost-account-root-password.age;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Linux kernel - Using a stable LTS kernel.
  # Check if the latest kernel is used:
  # ls -l /run/{booted,current}-system/kernel*
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_1;
  boot.extraModulePackages = with config.boot.kernelPackages; [ tuxedo-keyboard nvidia_x11 ];
  boot.blacklistedKernelModules = [
    # https://www.kernel.org/doc/html/latest/i2c/busses/i2c-nvidia-gpu.html
    "i2c_nvidia_gpu"
  ];

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
  i18n.supportedLocales = [ "all" ];
  console = {
    font = "Lat2-Terminus16";
    keyMap = "es";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.xkb.layout = "esrodk,es,dk,ro";
  # TODO: Disable because of nonfree license. Then find a solution for HDMI output.
  services.xserver.videoDrivers = [ "nvidia" ];

  # Disable unused xserver packages.
  services.xserver.excludePackages = with pkgs; [
    xterm
  ];

  # Adding an extra layout.
  services.xserver.xkb.extraLayouts.esrodk.description = "Spanish +ro/dk diacritics";
  services.xserver.xkb.extraLayouts.esrodk.languages = ["spa"];
  services.xserver.xkb.extraLayouts.esrodk.symbolsFile = /etc/nixos/esrodk;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Disable unused gnome packages.
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

  # Gnome changes.
  services.xserver.desktopManager.gnome.extraGSettingsOverridePackages = with pkgs; [
    gnome-terminal
  ];
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
      [org.gnome.Terminal.Legacy.Settings]
      theme-variant='dark'
  '';
  
  # Enable gnome-keyring.
  services.gnome.gnome-keyring.enable = true;
  

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplipWithPlugin ];

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
  users.users.daniel.isNormalUser = true;
  users.users.daniel.home = "/home/daniel";
  users.users.daniel.description = localhost-account-daniel-fullname;
  users.users.daniel.hashedPasswordFile = localhost-account-daniel-password;
  users.users.daniel.extraGroups = [
    "wheel"
    "docker"
    "audio"
    "libvirtd"
    "dialout"
  ];

  # The root user.
  users.users.root.hashedPasswordFile = localhost-account-root-password;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    # Development.
    firefox-devedition-bin
    php82
    kcachegrind graphviz
    fontforge-gtk
    vscodium
    arduino
    insomnia
    dbeaver-bin
    nixpkgs-review
    nix-prefetch
    nix-serve

    # Drivers and Firmware.
    hplipWithPlugin
    cups ntfs3g

    # Desktop apps.
    gnome-tweaks
    gnome-network-displays
    freerdp
    gparted
    evolutionWithPlugins
    firefox-bin
    tor-browser-bundle-bin
    qbittorrent
    ungoogled-chromium
    meld
    strawberry
    osdlyrics
    gimp
    pdfarranger
    inkscape
    signal-desktop
    vlc lbry
    gcstar
    czkawka
    protonvpn-gui
    filezilla
    ventoy
    #bitcoin - disabled 09072024, fails to build
    
    # Electron apps.
    element-desktop
    drawio
    discord
    go2tv simple-dlna-browser

    #Localization
    poedit
    aspell
    aspellDicts.ro

    # CLI Utilities.
    lshw
    wget
    git
    cpufrequtils
    yt-dlp
    ffmpeg
    dconf
    jq
    shntool
    flac
    cuetools
    asciinema
    tree
    usbutils
    nmap
    nix-tree
    inetutils
    openssl
    android-tools
    adb-sync
    scrcpy
    p7zip
    nnn
    debootstrap
    screen
    xorriso
    hdparm

    # Agenix secret management.
    (pkgs.callPackage "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/pkgs/agenix.nix" {})

    # Research & Text editing tools.
    libreoffice-fresh

    # Streaming & Recording.
    obs-studio
    shotcut
    kdenlive
    mediainfo
    glaxnimate

    # Virtualization.
    virt-manager
    docker-compose

    # Games.
    xonotic
    superTux
    superTuxKart
    mars

    # P2P.
    radarr
    #eiskaltdcpp - disabled 09072024, fails to build

    # Temporary.
    gnome-multi-writer
    woeusb
  ];

  # Local postgresql server.
  services.postgresql.enable = true;
  services.postgresql.authentication = "host all all 127.0.0.1/32 password";

  # Still enabled because of nvidia firmware.
  nixpkgs.config.allowUnfree = true;

  programs.dconf.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.enableNvidia = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.banner = banner;
  services.openssh.settings.PubkeyAuthentication = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22   # OpenSSH
    3000 # EiskaltDC++
    3001 # EiskaltDC++
    3389 # RDP connections
    3333 # LBRY Dameon
    4444 # LBRY Streams
    5567 # LBRY P2P
    6250 # EiskaltDC++ DHT
    50001 # LBRY Wallet
  ];
  networking.firewall.allowedUDPPorts = [
    3000 # EiskaltDC++
    3001 # EiskaltDC++
    6250 # EiskaltDC++ DHT
    4444 # LBRY Streams
  ];

  # Enable fish as the default shell.
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  users.motdFile = "/etc/nixos/motd.txt";

  # Fish customizations.
  programs.fish.interactiveShellInit = ''
    # Forcing true colors.
    set -g fish_term24bit 1
    # Empty fish greeting. @TODO: make it a fish option upstream.
    set -g fish_greeting ""
    # Printout customized output on shell init.
    echo "${banner}"
    echo "TUXEDO XA15"
    echo (date "+%T - %F")
  '';

  # Enable OpenGL
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

    # Modesetting is required.
  hardware.nvidia.modesetting.enable = true;

  # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
  hardware.nvidia.powerManagement.enable = false;
  # Fine-grained power management. Turns off GPU when not in use.
  # Experimental and only works on modern Nvidia GPUs (Turing or newer).
  hardware.nvidia.powerManagement.finegrained = false;

  # Use the NVidia open source kernel module (not to be confused with the
  # independent third-party "nouveau" open source driver).
  # Support is limited to the Turing and later architectures. Full list of
  # supported GPUs is at:
  # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
  # Only available from driver 515.43.04+
  # Currently alpha-quality/buggy, so false is currently the recommended setting.
  hardware.nvidia.open = false;

  # Enable the Nvidia settings menu,
  # accessible via `nvidia-settings`.
  hardware.nvidia.nvidiaSettings = true;

  # Optionally, you may need to select the appropriate driver version for your specific GPU.
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  environment.shellAliases = {
    # change nixos-rebuild to use my own version of nixpkgs.
    nixos-rebuild = "nixos-rebuild -I nixpkgs=/home/daniel/workspace/projects/nixpkgs --keep-going --log-format bar-with-logs";
  };

  # Initial version. Consult manual before changing.
  system.stateVersion = "22.05";

}
