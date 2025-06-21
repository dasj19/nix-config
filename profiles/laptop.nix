{ pkgs, ... }:
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
      gh
      inetutils
      shntool
      unrar
      usbutils
      w3m
      yt-dlp
      zip
      zstd

      # GUIs.
      brave
      czkawka
      drawio
      firefox
      flacon
      gimp
      halloy
      kando
      libreoffice-still
      pdfarranger
      poedit
      qbittorrent
      signal-desktop-bin
      tor-browser-bundle-bin
      ungoogled-chromium
      usbimager

      # Development.
      dbeaver-bin
      firefox-devedition
      fontforge-gtk
      insomnia
      vscodium

      # Drivers.
      ntfs3g
    ]; 
  };
}