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

    # Laptop packages.
    environment.systemPackages = with pkgs; [
      # CLIs.
      asciinema
      inetutils
      unrar
      w3m
      zip

      # GUIs.
      drawio
      firefox
      czkawka
      gimp
      gparted
      kando
      libreoffice-still
      pdfarranger
      ungoogled-chromium

      # Development.
      fontforge-gtk
      insomnia
      meld
      vscodium
      firefox-devedition
      dbeaver-bin
    ];
  };
}