{ pkgs, ... }:

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
    ./../../modules/games.nix
  ];

  options = {
    
  };

  config = {
    # Enable the X11 windowing system.
    services.xserver.enable = true;
    services.xserver.videoDrivers = [
      "nvidia"
    ];

    # Disable unnecessary xserver packages.
    services.xserver.excludePackages = with pkgs; [
      xterm
    ];

    # https://nix.dev/manual/nix/2.22/advanced-topics/cores-vs-jobs
    #nix.settings.max-jobs = 24;
    #nix.settings.cores = 1;

    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Needed for codeium.
    programs.nix-ld.enable = true;

    # List packages specific to this host installed in system profile.
    environment.systemPackages = with pkgs; [

      # Development.
      php
      php.packages.composer
      kcachegrind
      graphviz
      fontforge-gtk
      arduino
      symfony-cli
      nodejs_22
      pomodoro-gtk
      postgresql

      # Desktop apps.
      discord
      digikam
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
      poedit

      # CLI Utilities.
      android-tools
      adb-sync
      brightnessctl
      debootstrap
      iperf
      hdparm
      p7zip
      mariadb
      nnn # compare with lf
      scrcpy
      xorriso

      # Streaming & Recording.
      obs-studio
      shotcut
      kdenlive
      mediainfo
      glaxnimate
      mkvtoolnix

      # Virtualization.
      virt-manager
      virtiofsd

      # P2P.
      bitcoin
      radarr
      soulseekqt
      sabnzbd
      kodi

      # support both 32- and 64-bit applications
      wineWowPackages.stable
      # winetricks (all versions)
      winetricks
      # native wayland support (unstable)
      wineWowPackages.waylandFull
    ];

    # NETWORKING.
    networking.hostName = "tuxedo-xa15";

    networking.useDHCP = false;
    networking.interfaces.enp3s0f1.useDHCP = true;
    networking.interfaces.wlp4s0.useDHCP = true;

    # Open ports in the firewall.
    networking.firewall.allowedTCPPorts = [
      22    # OpenSSH
      3389  # RDP connections
      3333  # LBRY Daemon
      4444  # LBRY Streams
      5567  # LBRY P2P
      50001 # LBRY Wallet
    ];
    networking.firewall.allowedUDPPorts = [
      4444  # LBRY Streams
    ];

    # Use suspend and hibernate instead of suspend. Use: 'systemctl suspend' to test.
    systemd.services."systemd-suspend-then-hibernate".aliases = [ "systemd-suspend.service" ];

    # Virtualization.
    virtualisation.docker.enable = true;
    virtualisation.docker.enableOnBoot = false;
    virtualisation.libvirtd.enable = true;
    virtualisation.waydroid.enable = true;

    # Initial version. Consult manual before changing.
    system.stateVersion = "22.05";
  };
}
