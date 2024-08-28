{ pkgs, ... }:
{
  imports = [
    # Modules.
    ./../modules/audio.nix
    ./../modules/gnome.nix
    # Profiles.
    ./base.nix
  ];
  # Laptop packages.
  environment.systemPackages = with pkgs; [
    # Nix ecosystem.
    nix-search-cli
    nixpkgs-review

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