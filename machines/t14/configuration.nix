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
    (callPackage ./../../pkgs/duckduckgo-chat-cli.nix { }) # DuckDuckGo AI chat client.
    lrcget # Lyrics downloader.

    # Development.
    devenv # control development environments with nix.
    go
    mkcert # creates development environment certificates. # cspell:disable-line
    php83 # PHP.
    php83Packages.composer # Composer package manager for PHP.

    # GUI.
    gcstar # Collection manager.
    gnome-network-displays # Screen casting over Miracast.
    simple-scan # Paper scanning software.

    # P2P.
    nicotine-plus # soulseek client.
    sabnzbd # nzb client.
  ];

  # NixOS runs wpa_supplicant as non-root, and the NetworkManager policy denies messages to it by
  # default. This drops signals like DeviceFound, so NetworkManager never sees any Wi-Fi Direct peer.
  services.dbus.packages = [
    (pkgs.writeTextDir "share/dbus-1/system.d/wpa-supplicant-networkmanager.conf" ''
      <!DOCTYPE busconfig PUBLIC
       "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
       "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
      <busconfig>
        <policy group="wpa_supplicant">
          <allow send_destination="org.freedesktop.NetworkManager" send_type="signal"/>
        </policy>
      </busconfig>
    '')
  ];

  # The wpa_supplicant module restarts it when a wlan interface appears or disappears, which
  # includes the Wi-Fi Direct group interface it creates itself, aborting every connection.
  services.udev.extraRules = lib.mkMerge [
    (lib.mkBefore ''
      SUBSYSTEM=="net", KERNEL=="p2p-*", GOTO="wifi_direct_end"
    '')
    (lib.mkAfter ''
      LABEL="wifi_direct_end"
    '')
  ];

  # Enable virtualization.
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  # Network bridge between vm guest and host.
  virtualisation.libvirtd.allowedBridges = [ "virbr0" ]; # cspell:disable-line

  # Measures USB traffic bandwidth.
  programs.usbtop.enable = true;

  # Use the hostup1 nix store as binary cache, after cache.nixos.org (priority 40).
  # Trusted without signatures, root already uses ssh to hostup1 for remote builds.
  nix.settings.substituters = [ "ssh-ng://hostup1?trusted=true&priority=50" ];

  # Networking settings.
  networking.hostName = "t14";

  networking.hosts = {
    "127.0.0.1" = [
      "localhost"
      "archivebox.localhost"
      "admin.archivebox.localhost"
    ];
  };

  # Only on the Wi-Fi Direct groups of gnome-network-displays, numbered per connection.
  networking.firewall.interfaces."p2p-wlp0s20-+" = {
    allowedTCPPorts = [
      7236 # Miracast RTSP
    ];
    allowedUDPPorts = [
      67 # DHCP
    ];
  };

  # State version. Consult manual before changing.
  system.stateVersion = "26.05";
}
