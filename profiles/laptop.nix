{ pkgs, ... }:
{
  imports = [
    # Profiles.
    ./base.nix
    # Modules.
    ./../modules/audio.nix
    ./../modules/browsers.nix
    ./../modules/builder.nix
    ./../modules/gnome.nix
    ./../modules/stylix.nix
  ];

  config = {

    services.journald.extraConfig = "MaxRetentionSec=1week";

    # Laptop packages.
    environment.systemPackages = with pkgs; [
      # CLIs.
      asciinema
      bchunk
      cuetools
      dconf
      ffmpeg-full
      flac
      gh
      inetutils
      khard
      neo-cowsay
      shotcut
      shntool
      speedtest-cli
      subtitlecomposer
      unrar
      usbutils
      w3m
      yt-dlp
      zip
      zstd

      # GUIs.
      czkawka
      drawio
      element-desktop
      filezilla
      flacon
      flameshot
      gimp
      halloy
      kando
      libreoffice-still
      pdfarranger
      poedit
      qbittorrent
      signal-desktop-bin
      usbimager

      # Development.
      dbeaver-bin
      fontforge-gtk
      insomnia
      vscodium

      # Drivers.
      ntfs3g
    ]; 
  };
}