/*
  * tuxedo-xa15: my old powerful but noisy laptop
  * model: Tuxedo Book XA 15
  *
  * Notes:
  *  - no longer used as a daily driver.
  *  - used to test heavy offline-AI
  *  - sometimes booted into Batocera from an external SDD.
*/
{
  lib,
  pkgs,
  ...
}:
let
  php = pkgs.php84.buildEnv {
    extensions =
      {
        enabled,
        all,
      }:
      enabled
      ++ (with all; [
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
    # Hardware config.
    ./hardware.nix

    # Profile.
    ./../../profiles/laptop.nix
    # DE.
    ./../../modules/gnome.nix
    # Modules.
    ./../../modules/ai.nix
    ./../../modules/non-free.nix
  ];

  services.displayManager.gdm.enable = lib.mkForce true;
  services.desktopManager.gnome.enable = lib.mkForce true;
  programs.uwsm.enable = lib.mkForce false;
  programs.hyprland.enable = lib.mkForce false;
  programs.hyprland.withUWSM = lib.mkForce false;
  programs.hyprland.xwayland.enable = lib.mkForce false;
  programs.hyprlock.enable = lib.mkForce false;
  services.greetd.enable = lib.mkForce false;

  # Disable unused xserver packages.
  services.xserver.excludePackages = with pkgs; [
    xterm
  ];

  # NETWORKING.
  networking.hostName = "tuxedo-xa15";

  networking.networkmanager.enable = true;
  # Enable only the needed plugins.
  # Avoids # jun 29 23:04:28 t14 dbus-daemon[999]: Unknown username "nm-openconnect" in message bus configuration file
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openvpn
  ];

  networking.useDHCP = false;
  networking.interfaces.enp3s0f1.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22 # OpenSSH
    3389 # RDP connections
    3333 # LBRY Daemon
    4444 # LBRY Streams
    5567 # LBRY P2P
    50001 # LBRY Wallet
  ];
  networking.firewall.allowedUDPPorts = [
    4444 # LBRY Streams
  ];

  networking.hosts = {
    "127.0.0.1" = [
      "localhost"
      "devbox.dev"
    ];
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
    gparted
    lbry
    meld
    proton-vpn

    #Localization
    aspell
    aspellDicts.ro

    # CLI Utilities.
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

    # Temporary.
    iperf
    openssl

    # Games.
    evtest
    oversteer
    linuxConsoleTools
    gamepad-tool
  ];

  # Needed for codeium.
  programs.nix-ld.enable = true;

  programs.dconf.enable = true;

  # Enable virtualisation daemons.
  #virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false;
  virtualisation.waydroid.enable = true;

  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;

  # tuxedo-xa15 has a total of 32 cores.
  # use at most 4 corse per jobs, and max 8 parallel jobs in total.
  # @see https://nix.dev/manual/nix/2.22/advanced-topics/cores-vs-jobs
  nix.settings.max-jobs = lib.mkForce 8;
  nix.settings.cores = lib.mkForce 4;

  # Non-free software whitelist / shame list.
  allowedUnfree = [
    # Game tools.
    "gamepad-tool"

    # Graphic drivers.
    "nvidia-x11"
    "nvidia-settings"

    # AI stuff.
    "open-webui"

    # GUI.
    "discord"

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
    "libcufile"
    "libcusparse_lt"
    "cudnn"
  ];

  # Consult manual before changing.
  system.stateVersion = "26.05";
}
