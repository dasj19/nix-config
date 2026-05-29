# laptop: profile meant to be inherited by all the laptop machine configurations.
# contains: the base profile + laptop-specific modules.

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

    # Manage firmware updates.
    services.fwupd.enable = true;

    # A Fuse filesystem that returns symlinks to executables
    # based on the PATH of the requesting process.
    services.envfs.enable = true;

    # Non-free software for laptop.
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
      asciinema                   # Terminal session recorder.
      bchunk                      # converts CD images from BIN/CUE to ISO and CDR tracks.
      claude-code                 # Premium AI CLI client.
      localtunnel                 # CLI interface for the localtunnel service.
      #cron
      cuetools                    # Utilities for working with cue files and toc files.
      dconf                       # Desktop-environment conf editor.
      fcron                       # Needed by backintime. @todo fix upstream.
      ffmpeg-full                 # Record, convert and stream audio and video.
      flac                        # Tools for encoding and decoding the FLAC lossless audio file format.
      gh                          # Github CLI tool.
      github-copilot-cli          # Copilot AI CLI client.
      jujutsu                     # Git-compatible alternative VCS.
      khard                       # CLI for managing contacts.
      tealdeer                    # Fast implementation of tldr.

      neo-cowsay                  # New go implementation of cowsay.
      shotcut                     # Cross-platform video editor.
      shntool                     # Multi-purpose WAVE data processing and reporting utility.
      speedtest-cli               # CLI Internet speed tester.
      subtitlecomposer            # Open source text-based subtitle editor.
      unrar                       # Proprietary rar unpacker.
      usbutils                    # Tools for working with USB devices
      yt-dlp                      # Versatile media downloader.
      zip                         # Compressor for zip files.
      zstd                        # Zstandard real-time compression algorithm.

      # Libraries.
      hunspell                    # Spellchecker.
      hunspellDicts.da_DK         # Danish dictionary for hunspell.
      hunspellDicts.en_US         # American english dictionary for hunspell.
      hunspellDicts.ro_RO         # Romanian dictionary for hunspell.
      noto-fonts-cjk-serif-static # Font to support chinese-japanese-korean.

      # GUIs.
      backintime-qt               # Simple graphic backup tool.
      czkawka                     # Tool to remove unnecessary files.
      drawio                      # Diagram creation tool.
      element-desktop             # Matrix chat client.
      filezilla                   # FTP client.
      flameshot                   # Screenshot tool.
      gimp                        # Image manipulation software,
      lbry                        # Client for the LBRY protocol.
      libreoffice-still           # Secondary office suite.
      meld                        # Visual diff merger.
      onlyoffice-desktopeditors   # Primary office suite.
      pdfarranger                 # Basic PDF editor.
      #qalculate-gtk              # Classic calculator.
      qbittorrent                 # Torrent client.
      signal-desktop              # Encrypted private messenger.
      usbimager                   # Bootable USB creator.
      xournalpp                   # Advanced PDF editor.

      # Development.
      dbeaver-bin                 # Database administration.
      # fontforge-gtk
      insomnia                    # Request debugger.
      vscodium                    # IDE.

      # Drivers.
      ntfs3g                      # NTFS drivers and utilities.
    ];
  };
}
