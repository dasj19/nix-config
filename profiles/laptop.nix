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
      brasero
      brave
      czkawka
      dconf-editor
      drawio
      evolution
      firefox
      flacon
      gimp
      gparted
      halloy
      kando
      libreoffice-still
      pdfarranger
      poedit
      qbittorrent
      remmina
      signal-desktop-bin
      tor-browser-bundle-bin
      ungoogled-chromium
      usbimager
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