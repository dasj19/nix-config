# laptop: profile meant to be inherited by all the laptop machine configurations.
# scope: laptops
# contains: the base profile + laptop-specific modules.

{
  config,
  gitSecrets,
  lib,
  pkgs,
  ...
}:

let
  # Shown under the passphrase field of the Plymouth LUKS prompt, same as on hyprlock.
  luksMessage = "If found return to the owner! ${gitSecrets.danielFullname} ${gitSecrets.danielPersonalEmail} ${gitSecrets.danielPhoneNumber}";
in
{
  imports = [
    # Profiles.
    ./base.nix
    # Modules.
    ./../modules/audio.nix
    ./../modules/bluetooth.nix
    ./../modules/browsers.nix
    ./../modules/non-free.nix
    ./../modules/stylix.nix
  ];

  # Laptops move between networks.
  networking.networkmanager.enable = true;

  # Builds max 8 parallel jobs at once using at most 4 cores per job.
  # Laptops have at least 8 cores, override per machine when needed.
  # @see https://nix.dev/manual/nix/2.22/advanced-topics/cores-vs-jobs
  nix.settings.max-jobs = 8;
  nix.settings.cores = 4;

  # A Fuse filesystem that returns symlinks to executables
  # based on the PATH of the requesting process.
  services.envfs.enable = true;

  # Show a custom message on the Plymouth LUKS prompt, hidden when the initrd ends.
  boot.initrd.systemd.services.plymouth-luks-message = lib.mkIf config.boot.plymouth.enable {
    description = "Show a message on the Plymouth LUKS prompt";
    # cryptsetup-pre.target is passive, so it has to be pulled in to order against it.
    wantedBy = [ "cryptsetup.target" ];
    wants = [ "cryptsetup-pre.target" ];
    before = [ "cryptsetup-pre.target" ];
    after = [ "plymouth-start.service" ];
    unitConfig.DefaultDependencies = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = ''/bin/plymouth display-message --text="${luksMessage}"'';
      ExecStop = ''/bin/plymouth hide-message --text="${luksMessage}"'';
    };
  };

  # Non-free software for laptop.
  allowedUnfree = [
    # Libraries.
    "unrar"
    # GUI.
    "drawio"
    # VSCodium extensions, used in home/modules/vscodium.nix.
    # Unclear why this is marked as non-free. @todo: check upstream.
    # cspell:disable-next-line
    "vscode-extension-bmewburn-vscode-intelephense-client"
  ];

  # Laptop packages.
  environment.systemPackages = with pkgs; [
    # CLIs.
    asciinema # Terminal session recorder.
    bchunk # converts CD images from BIN/CUE to ISO and CDR tracks.
    cuetools # Utilities for working with cue files and toc files.
    dconf # Desktop-environment conf editor.
    fcron # Needed by backintime. @todo fix upstream.
    ffmpeg-full # Record, convert and stream audio and video.
    flac # Tools for encoding and decoding the FLAC lossless audio file format.
    jujutsu # Git-compatible alternative VCS.
    khard # CLI for managing contacts.
    localtunnel # CLI interface for the localtunnel service.
    tealdeer # Fast implementation of tldr.

    neo-cowsay # New go implementation of cowsay.
    shntool # Multi-purpose WAVE data processing and reporting utility.
    shotcut # Cross-platform video editor.
    speedtest-cli # CLI Internet speed tester.
    subtitlecomposer # Open source text-based subtitle editor.
    unrar # Proprietary rar unpacker.
    yt-dlp # Versatile media downloader.
    zip # Compressor for zip files.
    zstd # Zstandard real-time compression algorithm.

    # Libraries.
    hunspell # Spellchecker.
    hunspellDicts.da_DK # Danish dictionary for hunspell.
    hunspellDicts.en_US # American english dictionary for hunspell.
    hunspellDicts.ro_RO # Romanian dictionary for hunspell.
    noto-fonts-cjk-serif-static # Font to support chinese-japanese-korean.

    # GUIs.
    backintime-qt # Simple graphic backup tool.
    czkawka # Tool to remove unnecessary files.
    drawio # Diagram creation tool.
    element-desktop # Matrix chat client.
    euro-office-desktopeditors # Primary office suite.
    filezilla # FTP client.
    flameshot # Screenshot tool.
    gimp # Image manipulation software,
    lbry # Client for the LBRY protocol.
    libreoffice # Secondary office suite.
    meld # Visual diff merger.
    onlyoffice-desktopeditors # Tertiary office suite.
    pdfarranger # Basic PDF editor.
    qalculate-gtk # Classic calculator.
    qbittorrent # Torrent client.
    signal-desktop # Encrypted private messenger.
    usbimager # Bootable USB creator.
    xournalpp # Advanced PDF editor.

    # Development.
    dbeaver-bin # Database administration.
    # fontforge-gtk
    insomnia # Request debugger.
    vscodium # IDE.
  ];
}
