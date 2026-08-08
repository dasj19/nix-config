# t14: my daily driver laptop
# scope: machine
#
# Notes:
#  - any offline AI work has to be done on CPU which is slow.
#  - sudo-rs is set up to be used using fingerprint first
#    but has password prompt as fallback.
#

{
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Hardware config.
    ./hardware.nix

    # Development environment.
    ./development.nix

    # Profile.
    ./../../profiles/laptop.nix

    # Desktop Environment.
    ./../../modules/hyprland.nix

    # Modules.
    ./../../modules/ai.nix
    ./../../modules/audio.nix
    ./../../modules/non-free.nix
  ];

  # Non-free software whitelist / shame list.
  allowedUnfree = [
    # GUI.
    "discord"
  ];

  # t14 has a total of 8 cores.
  # Builds max 8 parallel jobs at once using at most 4 cores per job.
  # @see https://nix.dev/manual/nix/2.22/advanced-topics/cores-vs-jobs
  nix.settings.max-jobs = lib.mkForce 8;
  nix.settings.cores = lib.mkForce 4;

  # System-wide packages.
  environment.systemPackages = with pkgs; [
    # CLI.
    apkeep # Android APK downloader.
    lrcget # Lyrics downloader.

    # GUI.
    gcstar # Collection manager.
    discord # Modern but non-free chat service.
    xsane # Paper scanning software.

    # P2P.
    nicotine-plus # soulseek client.
    sabnzbd # nzb client.
  ];

  # Gnome's policy kit.
  security.polkit.enable = true;

  # Enable virtualization.
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Measures USB traffic bandwidth.
  programs.usbtop.enable = true;

  # Networking settings.
  networking.hostName = "t14";
  networking.networkmanager.enable = true;

  # State version. Consult manual before changing.
  system.stateVersion = "26.05";
}
