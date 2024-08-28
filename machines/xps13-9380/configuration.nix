{ config, pkgs, lib, gitSecrets, sopsSecrets, nixos-artwork, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Profiles.
    ./../../profiles/laptop.nix
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
    5353 # Avahi
  ];
  networking.networkmanager.enable = true;

  # Host specific packages.
  environment.systemPackages = with pkgs; [
    # Development.
    dart-sass
    docker-compose
    filezilla
    jekyll
    php83
    php83Packages.composer
    python3

    # Tempporary.
    heimdall
    heimdall-gui
    libusb1
    usbutils
    xd
    pkgs.tt
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

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

  nixpkgs.config.allowUnfree = true;

  # Check documentation if you want/need to change this.
  system.stateVersion = "22.11";
}
