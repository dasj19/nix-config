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
      speedtest-cli
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
      flacon
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