{ config, lib, pkgs, ... }:

let
  php = pkgs.php84.buildEnv {
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
      # Enable opening of files in vscodium.
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
    ./../../modules/ai.nix
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

  networking.hosts = {
    "127.0.0.1" = [ "localhost" "devbox.dev" ];
  };

  # SOFTWARE.

  # Use suspend and hibernate instead of suspend. Use: 'systemctl suspend' to test.
  systemd.services."systemd-suspend-then-hibernate".aliases = [ "systemd-suspend.service" ];

  services.fwupd.enable = true;

  # Manage the touchpad with libinput.
  services.libinput.enable = true;

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
    linux-firmware # needed for bluetooth firmware.

    # Desktop apps.
    discord
    element-desktop
    filezilla
    #gcstar
    gimp
    gparted
    inkscape
    lbry
    meld
    osdlyrics
    protonvpn-gui

    #Localization
    aspell
    aspellDicts.ro

    # CLI Utilities.
    android-tools
    adb-sync
    hdparm
    iat
    killall
    mariadb
    nnn # compare with lf
    nvtopPackages.full
    p7zip
    scrcpy
    xorriso

    # Streaming & Recording.
    obs-studio
    shotcut
    mediainfo
    mkvtoolnix

    # Virtualization.
    virt-manager
    virtiofsd

    # P2P.
    bitcoin
    radarr
    eiskaltdcpp
    nicotine-plus
    sabnzbd

    # Temporary.
    iperf
    kodi
    bitmagnet
    openssl

    # Games.
    evtest
    oversteer
    linuxConsoleTools
    gamepad-tool
    retroarch-joypad-autoconfig
    qjoypad
    retroarchFull
    retroarch-assets

    # support both 32- and 64-bit applications
    wineWowPackages.stable
    # winetricks (all versions)
    winetricks
    # native wayland support (unstable)
    wineWowPackages.waylandFull
  ];

  # Needed for codeium.
  programs.nix-ld.enable = true;

  programs.dconf.enable = true;
  
  # Enable virtualisation daemons.
  #virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false;
  virtualisation.waydroid.enable = true;

  # Enable virtualbox.
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  users.users.daniel.extraGroups = [
    "vboxusers"
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PubkeyAuthentication = true;

  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;

  # https://nix.dev/manual/nix/2.22/advanced-topics/cores-vs-jobs
  nix.settings.max-jobs = 24;
  nix.settings.cores = 1;

  # Non-free software whitelist / shame list.
  nixpkgs.config.allowUnfree = false;
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
    # Printer drivers.
    "hplip" 

    # Game emulation cores.
    "libretro-fbalpha2012"
    "libretro-fbneo"
    "libretro-fmsx"
    "libretro-genesis-plus-gx"
    "libretro-mame2000"
    "libretro-mame2003"
    "libretro-mame2003-plus"
    "libretro-mame2010"
    "libretro-mame2015"
    "libretro-opera"
    "libretro-picodrive"
    "libretro-snes9x"
    "libretro-snes9x2002"
    "libretro-snes9x2005"
    "libretro-snes9x2005-plus"
    "libretro-snes9x2010"
    "gamepad-tool"

    # Graphic drivers.
    "nvidia-x11"
    "nvidia-settings"

    # Virtualization.
    "Oracle_VirtualBox_Extension_Pack"
    "virtualbox"

    # Proprietary software.
    "android-sdk-platform-tools"
    "discord"
    "drawio"
    "soulseekqt"
    "unrar"

    # Machine learning tools - ollama-cuda dependencies.
    "cuda_cccl"
    "cuda_nvcc"
    "cuda_cudart"
    "libcublas"

    # nvtop dependencies.
    "cuda-merged"
    "cuda_cuobjdump"
    "cuda_gdb"
    "cuda_nvdisasm"
    "cuda_nvprune"
    "cuda_cupti"
    "cuda_cuxxfilt"
    "cuda_nvml_dev"
    "cuda_nvrtc"
    "cuda_nvtx"
    "cuda_profiler_api"
    "cuda_sanitizer_api"
    "libcufft"
    "libcurand"
    "libcusolver"
    "libnvjitlink"
    "libcusparse"
    "libnpp"
  ];

  # Initial version. Consult manual before changing.
  system.stateVersion = "22.05";
}
