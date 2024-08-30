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
    asciinema
    bchunk
    cuetools
    dconf
    ffmpeg
    flac
    inetutils
    shntool
    unrar
    usbutils
    w3m
    xar
    yt-dlp
    zip
    zstd

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