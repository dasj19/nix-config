{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # Profiles.
    ./base.nix
    # Modules.
    ./../modules/audio.nix
    ./../modules/bluetooth.nix
    ./../modules/browsers.nix
    ./../modules/builder.nix
    ./../modules/gnome.nix
    ./../modules/hyprland.nix
    ./../modules/stylix.nix
    ./../modules/non-free.nix
  ];

  config = {
    # Preferred laptop Linux kernel - latest zen kernel.
    # @see https://github.com/zen-kernel/zen-kernel/wiki/FAQ
    # Check if kernel was updated: ls -l /run/{booted,current}-system/kernel*
    boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_zen;

    services.journald.extraConfig = "MaxRetentionSec=1week";

    # Enable fwupd to manage firmware updates.
    services.fwupd.enable = true;

    allowedUnfree = [
      # CLI.
      "github-copilot-cli"
      # Libraries.
      "unrar"
      # GUI.
      "drawio"
    ];

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
      github-copilot-cli
      khard # CLI for managing contacts.
      tealdeer # Fast implementation of tldr.

      neo-cowsay
      shotcut
      shntool
      speedtest-cli
      subtitlecomposer
      unrar
      usbutils
      yt-dlp
      zip
      zstd

      # Libraries.
      hunspell
      hunspellDicts.da_DK
      hunspellDicts.en_US
      hunspellDicts.ro_RO

      # GUIs.
      czkawka
      drawio
      element-desktop
      filezilla
      flameshot
      gimp
      kando
      libreoffice-still
      onlyoffice-desktopeditors
      pdfarranger
      poedit
      qbittorrent
      signal-desktop
      usbimager

      # Development.
      dbeaver-bin
      # fontforge-gtk
      insomnia
      vscodium

      # Drivers.
      ntfs3g
    ];
  };
}
