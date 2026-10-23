# t14: my daily driver laptop
# scope: machine
#
# Notes:
#  - any offline AI work has to be done on CPU which is slow.
#  - sudo-rs is set up to be used using fingerprint first
#    but has password prompt as fallback.
#

{
  pkgs,
  ...
}:

{
  imports = [
    # Hardware config.
    ./hardware.nix

    # Profile.
    ./../../profiles/laptop.nix

    # Desktop Environment.
    ./../../modules/hyprland.nix

    # Modules.
    ./../../modules/ai.nix
    ./../../modules/development.nix
  ];

  # Non-free software whitelist / shame list.
  allowedUnfree = [
  ];

  # System-wide packages.
  environment.systemPackages = with pkgs; [
    # CLI.
    apkeep # Android APK downloader.
    (callPackage ./../../pkgs/archivebox.nix { }) # Self-hosted web archiving.
    lrcget # Lyrics downloader.

    # Development.
    ddev # tool for php-docker development. # cspell:disable-line
    devenv # control development environments with nix.
    mkcert # creates development environment certificates. # cspell:disable-line
    php83 # PHP.
    php83Packages.composer # Composer package manager for PHP.

    # GUI.
    gcstar # Collection manager.
    xsane # Paper scanning software.

    # P2P.
    nicotine-plus # soulseek client.
    sabnzbd # nzb client.
  ];

  # Enable virtualization.
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  # Network bridge between vm guest and host.
  virtualisation.libvirtd.allowedBridges = [ "virbr0" ]; # cspell:disable-line

  # Docker is enabled in development.nix, buildx handles building docker remotely.
  virtualisation.docker.extraPackages = [
    pkgs.docker-buildx # cspell:disable-line
  ];

  # Measures USB traffic bandwidth.
  programs.usbtop.enable = true;

  # Networking settings.
  networking.hostName = "t14";

  networking.hosts = {
    "127.0.0.1" = [
      "localhost"
      "archivebox.localhost"
      "admin.archivebox.localhost"
    ];
  };

  # State version. Consult manual before changing.
  system.stateVersion = "26.05";
}
