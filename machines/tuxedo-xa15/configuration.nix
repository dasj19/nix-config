# tuxedo-xa15: old Tuxedo Book XA 15 laptop.
# scope: machine
#
# No longer used as a daily driver. Used to test heavy offline-AI.
# Sometimes booted into Batocera from an external SSD.

{
  pkgs,
  config,
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
    ./../../modules/cuda-packages.nix
    ./../../modules/development.nix
  ];

  # NETWORKING.
  networking.hostName = "tuxedo-xa15";

  # Enable only the needed NetworkManager plugins.
  # Avoids # jun 29 23:04:28 t14 dbus-daemon[999]: Unknown username "nm-openconnect" in message bus configuration file
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openvpn
  ];

  networking.useDHCP = false;
  networking.interfaces.enp3s0f1.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
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
    ];
  };

  # SOFTWARE.

  # Use suspend and hibernate instead of suspend. Use: 'systemctl suspend' to test.
  systemd.services."systemd-suspend-then-hibernate".aliases = [ "systemd-suspend.service" ];

  # Manage the touchpad with libinput.
  services.libinput.enable = true;

  # List packages specific to this host installed in system profile.
  environment.systemPackages = with pkgs; [
    # Development.
    arduino
    graphviz
    php
    php.packages.composer
    pomodoro-gtk
    postgresql

    # Drivers and Firmware.
    linux-firmware # needed for bluetooth firmware.

    # Desktop apps.
    proton-vpn

    #Localization
    aspell
    aspellDicts.ro

    # CLI Utilities.
    hdparm
    iat
    nnn # compare with lf
    nvtopPackages.full
    p7zip
    scrcpy
    xorriso

    # Streaming & Recording.
    mediainfo
    mkvtoolnix
    obs-studio

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
    gamepad-tool
    linuxConsoleTools
    oversteer
  ];

  # Needed for codeium.
  programs.nix-ld.enable = true;

  # Enable virtualisation daemons.
  # Docker is enabled in development.nix, here it only starts on demand.
  virtualisation.docker.enableOnBoot = false;
  virtualisation.waydroid.enable = true;

  # Non-free software whitelist / shame list.
  allowedUnfree = config.cuda.allowedPackages ++ [
    # Game tools.
    "gamepad-tool"

    # Graphic drivers.
    "nvidia-x11"
    "nvidia-settings"
  ];

  # Consult manual before changing.
  system.stateVersion = "26.05";
}
