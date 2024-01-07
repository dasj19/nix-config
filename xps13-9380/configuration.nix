{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Agenix via fetchTarball
      "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/master.tar.gz"}/modules/age.nix"
    ];

  # Agenix secrets.
  age.secrets.daniel-fullname.file = /etc/nixos/secrets/daniel-fullname.age;
  age.secrets.daniel-password.file = /etc/nixos/secrets/daniel-password.age;
  age.secrets.root-password.file = /etc/nixos/secrets/root-password.age;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "xps13-9380";

  # Enable networking via network manager.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Enable I2P and its proxy.
  services.i2pd.enable = true;
  services.i2pd.proto.socksProxy.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.excludePackages = with pkgs; [
    xterm
  ];

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Exclude unnecessary GNOME programs.
  environment.gnome.excludePackages = with pkgs; [
    gnome-photos gnome.geary gnome.gnome-music
    gnome.gnome-weather gnome.gnome-clocks gnome.cheese
    gnome-tour gnome-connections gnome.gnome-logs
    gnome.gnome-maps
  ];

  # Configure keymap in X11
  services.xserver.layout = "es";

  # Adding an extra layout.
  services.xserver.extraLayouts.esrodk = {
    description = "Spanish +ro/dk diacritics";
    languages = ["dan" "eng" "rum" "spa"];
    symbolsFile = /etc/nixos/esrodk;
  };

  # Configure console keymap
  console.keyMap = "es";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Allow updating of password hashes.
  users.mutableUsers = false;
  # Unpriviledged user account with a secret description.
  users.users.daniel = {
    isNormalUser = true;
    description = lib.strings.fileContents config.age.secrets.daniel-fullname.path;
    hashedPasswordFile = config.age.secrets.daniel-password.path;
    extraGroups = [ "networkmanager" "wheel" "docker"];
  };
  users.users.root = {
    hashedPasswordFile = config.age.secrets.root-password.path;
  };

  environment.systemPackages = with pkgs; [
     # CLIs
     (pkgs.callPackage "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/pkgs/agenix.nix" {})
     nmap
     screen
     wget
     php82
     php82Packages.composer
     zip
     xar
     bchunk
     bsdiff
     python3
     yt-dlp
     git
     nixpkgs-review

     # GUIs
     firefox
     tvheadend
     libreoffice-still
     tor-browser-bundle-bin
     fontforge-gtk
     wineWowPackages.stable
     winetricks mono freetype fontconfig
     ghidra
     #chromium
     evolution
     gimp vlc
     qbittorrent
     tribler
     remmina
     #element-desktop
     #protonvpn-gui
     #signal-desktop

     # Defelopment.
     vscodium meld insomnia
     filezilla

     # Tempporary.
     #heimdall heimdall-gui
     libusb1 usbutils
     xd
  ];

  # Enable OpenGL support.
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

  # Virtualisation.
  virtualisation.docker.enable = true;
  virtualisation.waydroid.enable = true;
  virtualisation.libvirtd.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22 # OpenSSH
  ];
  networking.firewall.allowedUDPPorts = [
  ];

 # Enable fish as the default shell.
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Fish customizations.
  programs.fish.shellInit = ''
    echo "xps13-9380"
    echo (date "+%T - %F")
  '';
  programs.fish.interactiveShellInit = ''
    # Forcing true colors.
    set -g fish_term24bit 1
    # Empty fish greeting. @TODO: make it a fish option upstream.
    set -g fish_greeting ""
  '';

  # Check documentation if you want/need to change this.
  system.stateVersion = "22.11";
}
