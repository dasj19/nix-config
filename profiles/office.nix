{ pkgs, ... }:
{
  imports = [
    # Profiles.
    ./base.nix
    # Modules.
    ./../modules/audio.nix
    ./../modules/gnome.nix
  ];

  # Some office packages are unfree.
  nixpkgs.config.allowUnfree = true;

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
    evolutionWithPlugins
    firefox
    czkawka
    gimp
    gparted
    kando
    libreoffice-still
    remmina
    pdfarranger
    vlc
    tor-browser-bundle-bin
    ungoogled-chromium

    # Development.
    fontforge-gtk
    insomnia
    meld
    vscodium
    firefox-devedition-bin
    dbeaver-bin
  ];
}