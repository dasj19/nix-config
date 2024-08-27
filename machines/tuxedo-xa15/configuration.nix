{ config, lib, pkgs, gitSecrets, sopsSecrets, ... }:

let

  banner = lib.strings.fileContents "${./motd.txt}";
  
in

{
  
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Agenix for dealing with secrets.
    "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/modules/age.nix"
    # Unmerged code for tuxedo-drivers. @TODO: remove once it is merged in unstable, perpare a profile in nixos-hardware.
    # "${inputs.tuxedo-drivers}/nixos/modules/hardware/tuxedo-drivers.nix"
    
    # Modules.
    ./../../modules/audio.nix
    ./../../modules/fish.nix
    ./../../modules/gnome.nix
    ./../../modules/keyboard.nix
    ./../../modules/locale.nix
    ./../../modules/nix.nix
    ./../../modules/stylix.nix
    ./../../modules/users.nix
  ];

  # Emulate arm32 and arm64.
  boot.binfmt.emulatedSystems = [ "armv7l-linux" "aarch64-linux" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Linux kernel - Using a stable LTS kernel.
  # Check if the latest kernel is used:
  # ls -l /run/{booted,current}-system/kernel*
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;

  boot.blacklistedKernelModules = [
    # https://www.kernel.org/doc/html/latest/i2c/busses/i2c-nvidia-gpu.html
    "i2c_nvidia_gpu"
    # touchpad goes over i2c
    "psmouse"
  ];

  networking.hostName = "tuxedo-xa15";

  # Networking options.
  networking.useDHCP = false;
  networking.interfaces.enp3s0f1.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # TODO: Disable because of nonfree license. Then find a solution for HDMI output.
  services.xserver.videoDrivers = [ "nvidia" ];

  # Disable unused xserver packages.
  services.xserver.excludePackages = with pkgs; [
    xterm
  ];

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


  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    # Compiling.
    gnumake bison flex gcc clang

    # Cryptography.
    git-crypt
    sops

    # Development.
    firefox-devedition-bin
    php82
    kcachegrind
    graphviz
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
    bitcoin
    soulseekqt
    
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
    fastfetch

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
    eiskaltdcpp

    # Temporary.
    gnome-multi-writer
    woeusb
    brightnessctl
    keyleds
    openrgb
  ];

  # Local postgresql server.
  services.postgresql.enable = true;
  services.postgresql.authentication = "host all all 127.0.0.1/32 password";

  # Still enabled because of nvidia firmware.
  nixpkgs.config.allowUnfree = true;

  programs.dconf.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
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

  # HARDWARE SETTINGS.

  # Enable control of keyboard lights via openrgb.
  services.hardware.openrgb.enable = true;

  # AMD.
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
  # Enable ryzen_smu kernel driver.
  hardware.cpu.amd.ryzen-smu.enable = true;
  # Enable the Ryzen monitor.
  programs.ryzen-monitor-ng.enable = true;

  # Tuxedo keyboard support. (So that you can control the backlight).
  #hardware.tuxedo-drivers.enable = true;

  # Control programs.
  hardware.tuxedo-rs.enable = true;
  hardware.tuxedo-rs.tailor-gui.enable = true;

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
  hardware.nvidia.open = true; # trying true;

  # Enable the Nvidia settings menu,
  # accessible via `nvidia-settings`.
  hardware.nvidia.nvidiaSettings = true;

  # Optionally, you may need to select the appropriate driver version for your specific GPU.
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  # Initial version. Consult manual before changing.
  system.stateVersion = "22.05";

}
