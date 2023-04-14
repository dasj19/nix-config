# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let

  # Agenix strings:
  localhost-account-daniel-fullname = lib.strings.fileContents config.age.secrets.localhost-account-daniel-fullname.path;

in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Agenix for dealing with secrets.
      "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/modules/age.nix"
    ];

  # Agenix secrets.
  age.secrets.localhost-account-daniel-fullname.file = secrets/localhost-account-daniel-fullname.age;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "xps13-9310"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_DK.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Disable unused gnome packages.
  environment.gnome.excludePackages = with pkgs; [
    gnome-photos gnome.geary gnome.gnome-music
    gnome.gnome-weather gnome.gnome-clocks gnome.cheese
    gnome-tour gnome-connections gnome.gnome-logs
    gnome.gnome-maps
  ];

  # Configure keymap in X11
  services.xserver = {
    layout = "esrodk,es,dk,ro";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "es";

  # Adding an extra layout.
  services.xserver.extraLayouts.esrodk = {
    description = "Spanish +ro/dk diacritics";
    languages = ["spa"];
    symbolsFile = /etc/nixos/esrodk;
  };

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

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.daniel = {
    isNormalUser = true;
    description = localhost-account-daniel-fullname;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [ /* no user packages */ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Agenix secret management.
    (pkgs.callPackage "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/pkgs/agenix.nix" {})

    # CLI.
    nano git docker docker-compose tree platformsh #php81Packages.composer
    exa dos2unix bash
    # GUI.
    firefox firefox-devedition-bin chromium google-chrome opera
    slack evolution zoom-us
    vscodium meld insomnia dbeaver postman
    # Libraries.
    php81
  ];

  virtualisation.docker.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable fish as the default shell.
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Allowed shells.
  environment.shells = [ pkgs.bashInteractive pkgs.fish ];

  system.activationScripts = {
    bashsh.text =
      ''
        ln -sf /run/current-system/sw/bin/bash /bin/bash
      '';
  };

  # Enable expanding of aliases for bash globally. (Needed for gchooks project).
  #programs.bash.shellInit = ''
  #  shopt -s expand_aliases
  #'';

  networking.hosts = {
  "127.0.0.1" = [ "kdb" "kdk" "kirke" "orderflow" ];
  };

  environment.shellAliases = {
    # change nixos-rebuild to use my own version of nixpkgs.
    nixos-rebuild = "nixos-rebuild -I nixpkgs=/home/daniel/workspace/nixpkgs --keep-going";
    # Replace ls commands with exa counterparts.
    
    ls  = "exa";                                                         # ls replacement
    l   = "exa -lbF --git";                                              # list, size, type, git
    ll  = "exa -lbGF --git";                                             # long list
    llm = "exa -lbGd --git --sort=modified";                             # long list, modified date sort
    la  = "exa -lbhHigUmuSa --time-style=long-iso --git --color-scale";  # all list
    lx  = "exa -lbhHigUmuSa@ --time-style=long-iso --git --color-scale"; # all + extended list

    # specialty views
    lS  = "exa -1";      	                                         # one column, just names
    lt  = "exa --tree --level=2";                                        # tree
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

