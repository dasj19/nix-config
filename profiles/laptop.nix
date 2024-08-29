{ pkgs, ... }:
{
  imports = [
    # Profiles.
    ./base.nix
    # Modules.
    ./../modules/audio.nix
    ./../modules/gnome.nix
  ];

  # Some laptop packages are unfree.
  nixpkgs.config.allowUnfree = true;

  # Laptop packages.
  environment.systemPackages = with pkgs; [
    # CLIs.
    bchunk
    dconf
    eza
    ffmpeg
    git
    nmap
    screen
    shntool
    smartmontools
    tree
    unrar
    usbutils
    wget
    w3m
    xar
    yt-dlp
    zip
    zstd

    # Encryption.
    age
    git-crypt
    sops

    # GUIs.
    brasero
    cuetools
    dconf-editor
    evolution
    firefox
    fontforge-gtk
    ghidra
    gimp
    gparted
    halloy
    libreoffice-still
    poedit
    qbittorrent
    remmina
    tor-browser-bundle-bin
    vlc

    # Electron apps.
    element-desktop
    discord
    protonvpn-gui
    signal-desktop
    ungoogled-chromium

    # Development.
    insomnia
    meld
    vscodium
  ];
}