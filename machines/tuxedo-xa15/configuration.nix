{ config, lib, pkgs, ... }:

let
  php = pkgs.php81.buildEnv {
    extensions = { enabled, all }: enabled ++ (with all; [
      amqp
      ctype
      iconv
      intl
      mbstring
      openssl
      pdo_pgsql
      redis
      sodium
      tokenizer
      xsl
      xdebug 
    ]);
    extraConfig = ''
      # Enable opening of files in vscode.
      xdebug.file_link_format=vscodium://file/%f:%l
    '';
  };
in

{
  
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # Profile.
    ./../../profiles/laptop.nix
    # Modules.
    ./../../modules/games.nix
  ];

  # Disable unused xserver packages.
  services.xserver.excludePackages = with pkgs; [
    xterm
  ];

  # HARDWARE.

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [
    "nvidia"
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplipWithPlugin ];

  # Enable scanning support.
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];
  services.ipp-usb.enable = true;

  # AMD.
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  services.thermald.enable = true;

  # Tuxedo drivers support.
  hardware.tuxedo-drivers.enable = true;
  # Control programs.
  hardware.tuxedo-rs.enable = false;
  hardware.tuxedo-rs.tailor-gui.enable = false;

  # Enable OpenGL
  hardware.graphics.enable = true;
  # hardware.graphics.enable32Bit = true;
  # hardware.graphics.extraPackages = with pkgs; [
  #   mesa
  #   mesa.drivers
  # ];


  # Use the NVidia open source kernel module (not to be confused with the
  # independent third-party "nouveau" open source driver).
  # Support is limited to the Turing and later architectures. Full list of
  # supported GPUs is at:
  # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
  # Only available from driver 515.43.04+
  # Currently alpha-quality/buggy, so false is currently the recommended setting.
  hardware.nvidia.open = true;

  # Enable the Nvidia settings menu,
  # accessible via `nvidia-settings`.
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  # Needed for properly suspend.
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.modesetting.enable = true;

  # NETWORKING.
  networking.hostName = "tuxedo-xa15";

  networking.useDHCP = false;
  networking.interfaces.enp3s0f1.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  fileSystems."/mnt/md0" = {
    device = "10.0.10.182:/md0";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22   # OpenSSH
    3000 # EiskaltDC++
    3001 # EiskaltDC++
    3389 # RDP connections
    3333 # LBRY Daemon
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

  # SOFTWARE.

  # Emulate arm32 and arm64.
  boot.binfmt.emulatedSystems = [ "armv7l-linux" "aarch64-linux" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use suspend and hibernate instead of suspend. Use: 'systemctl suspend' to test.
  systemd.services."systemd-suspend-then-hibernate".aliases = [ "systemd-suspend.service" ];


  hardware.cpu.amd.ryzen-smu.enable = true;

  services.fwupd.enable = true;

  boot.kernelParams = [
    # Needed to avoid bad wakeup after suspend.
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_TemporaryFilePath=/tmp"
  ];
  boot.extraModulePackages = [
    config.boot.kernelPackages.nvidia_x11_beta
  ];

  # List packages specific to this host installed in system profile.
  environment.systemPackages = with pkgs; [

    # Development.
    php
    php.packages.composer
    #kcachegrind
    graphviz
    fontforge-gtk
    arduino
    symfony-cli
    nodejs_22
    pomodoro-gtk
    postgresql

    # Drivers and Firmware.
    ntfs3g

    # Desktop apps.
    discord
    element-desktop
    filezilla
    freerdp
    #gcstar
    gimp
    go2tv
    gparted
    inkscape
    lbry
    meld
    osdlyrics
    protonvpn-gui
    simple-dlna-browser
    strawberry
    tauon
    ventoy
    vlc    

    #Localization
    aspell
    aspellDicts.ro

    # CLI Utilities.
    android-tools
    adb-sync
    debootstrap
    hdparm
    iat
    mariadb
    nnn # compare with lf
    p7zip
    scrcpy
    xorriso

    # Streaming & Recording.
    obs-studio
    shotcut
    #kdenlive
    mediainfo
    glaxnimate
    mkvtoolnix

    # Virtualization.
    virt-manager
    virtiofsd

    # P2P.
    bitcoin
    radarr
    eiskaltdcpp
    soulseekqt
    sabnzbd

    # Temporary.
    brightnessctl
    keyleds
    openrgb
    iperf
    conda
    kodi
    bitmagnet

    # Games.
    evtest
    oversteer
    linuxConsoleTools
    gamepad-tool
    retroarch-joypad-autoconfig
    qjoypad
    retroarchFull
    retroarch-assets
    #emulationstation-de

    # support both 32- and 64-bit applications
    wineWowPackages.stable
    # winetricks (all versions)
    winetricks
    # native wayland support (unstable)
    wineWowPackages.waylandFull
  ];

  # Reqiured by emulationstation-de.
  nixpkgs.config.permittedInsecurePackages = [
    "freeimage-unstable-2021-11-01"
  ];

  # Needed for codeium.
  programs.nix-ld.enable = true;

  # Local postgresql server.
  #services.postgresql.enable = true;
  #services.postgresql.authentication = "host all all 127.0.0.1/32 password";

  programs.dconf.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false;
  virtualisation.waydroid.enable = true;

  # Enable virtualbox.
  nixpkgs.config.allowUnfree = true;
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  # Guest additions.
  virtualisation.virtualbox.guest.enable = true;
  virtualisation.virtualbox.guest.dragAndDrop = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PubkeyAuthentication = true;

  # https://nix.dev/manual/nix/2.22/advanced-topics/cores-vs-jobs
  nix.settings.max-jobs = 24;
  nix.settings.cores = 1;

  # Initial version. Consult manual before changing.
  system.stateVersion = "22.05";
}
