{ lib, pkgs, ... }:
{
  imports = [
    # Profiles.
    ./base.nix
    # Modules.
    ./../modules/audio.nix
    ./../modules/gnome.nix
    ./../modules/stylix.nix
  ];

  config = {
    
    # Some laptop packages are unfree.
    nixpkgs.config.allowUnfree = lib.mkDefault true;

    # Enable CUPS to print documents from laptops.
    services.printing.enable = true;
    services.printing.drivers = [ pkgs.hplipWithPlugin ];

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
      czkawka
      dconf-editor
      drawio
      evolutionWithPlugins
      firefox
      flacon
      ghidra
      gimp
      gparted
      halloy
      kando
      libreoffice-still
      pdfarranger
      poedit
      qbittorrent
      remmina
      signal-desktop
      tor-browser-bundle-bin
      ungoogled-chromium
      vlc

      # Development.
      dbeaver-bin
      firefox-devedition-bin
      fontforge-gtk
      insomnia
      meld
      vscodium
    ]; 
  };
}