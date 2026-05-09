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
    ./../modules/stylix.nix
    ./../modules/non-free.nix
  ];

  config = {

    services.journald.extraConfig = "MaxRetentionSec=1week";

    # Enable fwupd to manage firmware updates.
    services.fwupd.enable = true;

    allowedUnfree = [
      # CLI.
      "claude-code"
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
      claude-code
      cron
      cuetools
      dconf
      fcron
      ffmpeg-full
      flac
      gh
      github-copilot-cli
      jujutsu
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
      noto-fonts-cjk-serif-static # font to support chinese-japanese-korean.

      # GUIs.
      backintime-qt
      czkawka
      drawio
      element-desktop
      filezilla
      flameshot
      gimp
      lbry
      libreoffice-still
      meld
      onlyoffice-desktopeditors
      pdfarranger
      (pidgin.override {
        plugins = [
          pidginPackages.pidgin-osd
          (pkgs.callPackage ../pkgs/purple-discord.nix { })
          #(pkgs.callPackage ../pkgs/purple-presage.nix { })
          #pidginPackages.purple-plugin-pack
        ];
      })
      qalculate-gtk
      qbittorrent
      signal-desktop
      usbimager
      xournalpp

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
