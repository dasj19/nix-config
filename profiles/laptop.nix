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
    yt-dlp
    zip
    zstd

    # GUIs.
    brasero
    dconf-editor
    drawio
    evolutionWithPlugins
    firefox
    flacon
    czkawka
    ghidra
    gimp
    gparted
    kando
    halloy
    libreoffice-still
    poedit
    qbittorrent
    remmina
    pdfarranger
    vlc
    libreoffice-fresh
    signal-desktop
    ungoogled-chromium
    tor-browser-bundle-bin

    # Development.
    fontforge-gtk
    insomnia
    meld
    vscodium
    firefox-devedition-bin
    dbeaver-bin
  ];
}