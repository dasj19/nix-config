{ config, lib, pkgs, gitSecrets, sopsSecrets, ... }:

{
  
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Unmerged code for tuxedo-drivers. @TODO: remove once it is merged in unstable, prepare a profile in nixos-hardware.
    # "${inputs.tuxedo-drivers}/nixos/modules/hardware/tuxedo-drivers.nix"

    # Profile.
    ./../../profiles/laptop.nix
    # Modules.
    ./../../modules/games.nix
  ];

  # HARDWARE.

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # TODO: Disable because of non-free license. Then find a solution for HDMI output.
  services.xserver.videoDrivers = [ "nvidia" ];

  # Disable unused xserver packages.
  services.xserver.excludePackages = with pkgs; [
    xterm
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplipWithPlugin ];

  # Enable control of keyboard lights via openrgb.
  services.hardware.openrgb.enable = true;

  # AMD.
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
  # Enable ryzen_smu kernel driver.
  hardware.cpu.amd.ryzen-smu.enable = true;
  # Enable the Ryzen monitor.
  programs.ryzen-monitor-ng.enable = true;

  services.thermald.enable = true;

  # Tuxedo keyboard support. (So that you can control the backlight).
  #hardware.tuxedo-drivers.enable = true;

  # Control programs.
  #hardware.tuxedo-rs.enable = true;
  #hardware.tuxedo-rs.tailor-gui.enable = true;

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

  # Linux kernel - Using a stable LTS kernel.
  # Check if the latest kernel is used:
  # ls -l /run/{booted,current}-system/kernel*
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_10;

  boot.blacklistedKernelModules = [
    # https://www.kernel.org/doc/html/latest/i2c/busses/i2c-nvidia-gpu.html
    "i2c_nvidia_gpu"
    # touchpad goes over i2c
    "psmouse"
  ];

  hardware.new-lg4ff.enable = true;

  hardware.usb-modeswitch.enable = true;
  # boot.extraModprobeConfig = ''
  #   # G923 support (added HID_QUIRK_HAVE_SPECIAL_DRIVER)
  #   options usbhid quirks="0x046D:0xC267:0x080000,0x046D:0xC266:0x080000"
  # '';

  # List packages specific to this host installed in system profile.
  environment.systemPackages = with pkgs; [

    # Development.
    php83
    kcachegrind
    graphviz
    fontforge-gtk
    arduino

    # Drivers and Firmware.
    ntfs3g

    # Desktop apps.
    freerdp
    gparted
    meld
    strawberry
    osdlyrics
    gimp
    inkscape
    vlc
    lbry
    gcstar
    filezilla
    ventoy
    go2tv
    simple-dlna-browser

    #Localization
    poedit
    aspell
    aspellDicts.ro

    # CLI Utilities.
    android-tools
    adb-sync
    scrcpy
    p7zip
    nnn # compare with lf
    debootstrap
    xorriso
    hdparm

    # Streaming & Recording.
    obs-studio
    shotcut
    kdenlive
    mediainfo
    glaxnimate

    # Virtualization.
    virt-manager

    # P2P.
    radarr
    eiskaltdcpp
    bitcoin
    soulseekqt

    # Temporary.
    brightnessctl
    keyleds
    openrgb
    iperf

    # Games.
    evtest
    oversteer
    linuxConsoleTools
    gamepad-tool
    xboxdrv
    retroarch-joypad-autoconfig
    qjoypad
    retroarchFull
    retroarch-assets
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "freeimage-unstable-2021-11-01"
    # required by mkchromecast
    "python3.12-youtube-dl-2021.12.17"
  ];

  # Local postgresql server.
  services.postgresql.enable = true;
  services.postgresql.authentication = "host all all 127.0.0.1/32 password";

  programs.dconf.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PubkeyAuthentication = true;

  # https://nix.dev/manual/nix/2.22/advanced-topics/cores-vs-jobs
  nix.settings.max-jobs = 24;
  nix.settings.cores = 1;

  # Initial version. Consult manual before changing.
  system.stateVersion = "22.05";
}
