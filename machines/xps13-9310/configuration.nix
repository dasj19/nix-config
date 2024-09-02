{ config, lib, pkgs, gitSecrets, ... }:

let

  # Agenix strings:
  localhost-account-daniel-fullname = lib.strings.fileContents config.age.secrets.localhost-account-daniel-fullname.path;

  # Git secrets.
  localhost-alias1 = gitSecrets.xps139310HostAlias1;

in

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Agenix for dealing with secrets.
      "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/modules/age.nix"
      # Profiles.
      ./../../profiles/laptop.nix
    ];

  # Agenix secrets.
  age.secrets.localhost-account-daniel-fullname.file = secrets/localhost-account-daniel-fullname.age;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Latest kernel. For mic support.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "xps13-9310";

  # Enable networking
  networking.networkmanager.enable = true;

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

  # Hardware acceleration for intel based graphics cards.
  environment.variables = {
    VDPAU_DRIVER = lib.mkIf config.hardware.graphics.enable (lib.mkDefault "va_gl");
  };

  hardware.graphics.extraPackages = with pkgs; [
    (if (lib.versionOlder (lib.versions.majorMinor lib.version) "23.11") then vaapiIntel else intel-vaapi-driver)
    libvdpau-va-gl
    intel-media-driver
  ];

  # Enable sound with pipewire.
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

  # Underpriviledged user account.
  users.users.daniel = {
    isNormalUser = true;
    description = localhost-account-daniel-fullname;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [ /* no user packages */ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    # Agenix secret management.
    (pkgs.callPackage "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/pkgs/agenix.nix" {})


    # CLI.
    awscli2
    codeium
    php82Packages.composer
    php82Packages.php-codesniffer
    cypress
    docker
    docker-compose
    git
    goaccess
    jq
    nano
    pciutils
    platformsh
    tree
    wget
    xvfb-run
    yarn

    # Cryptography.
    git-crypt
    sops

    # Drivers and firmware.
    intel-gmmlib
    glibc

    # GUI.
    chromium
    drawio
    dbeaver-bin
    #element-desktop
    evolution
    filezilla
    firefox
    firefox-devedition-bin
    gimp
    gnome-tweaks
    google-chrome
    libreoffice-still
    meld
    insomnia
    opera
    tor-browser-bundle-bin
    slack
    vlc
    vscode
    vscodium
    zoom-us

    # Libraries.
    nodejs_20
    php82
    stdenv.cc.cc.lib

    # Temporary
    xorg.xorgserver
    microsoft-edge
  ];

  virtualisation.docker.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22 # OpenSSH
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];

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

  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [

    cypress
  ];

  programs.starship.enable = true;
  # Starship configuration.
  programs.starship.settings = {
    # No new line before the prompt.
    add_newline = false;
    # Module configuration.
    line_break = {
      disabled = true;
    };
    username = {
      show_always = true;
    };
    hostname = {
      ssh_only = false;
    };
    time = {
      disabled = false;
    };
    localip = {
      ssh_only = false;
      disabled = false;
    };
    sudo = {
      disabled = false;
    };
    status = {
      disabled = false;
      map_symbol = true;
    };
    git_status = {
      disabled = false;
      conflicted = "🏳";
      ahead = "🏎💨";
      behind = "😰";
      diverged = "😵";
      up_to_date = "✓";
      untracked = "🤷";
      stashed = "📦";
      modified = "📝";
      staged = "[++\($count\)](green)";
      renamed = "👅";
      deleted = "🗑";
    };
    php = {
      disabled = true;
    };
    nodejs = {
      disabled = true;
    };
  };


  environment.shellAliases = {
    # change nixos-rebuild to use my own version of nixpkgs.
    nixos-rebuild = "nixos-rebuild -I nixpkgs=/home/daniel/workspace/nixpkgs --log-format bar-with-logs --keep-going";

    xvfb = "/run/current-system/sw/bin/xvfb-run";
  };

  networking.hosts = {
    "127.0.0.1" = [ localhost-alias1 ];
  };

  # Initial state. Check the manual before changing the state!
  system.stateVersion = "23.05";

}


