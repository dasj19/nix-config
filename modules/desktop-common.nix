# desktop-common: settings shared by every desktop environment.
# scope: laptops
#
# Imported by the desktop modules (gnome.nix, hyprland.nix), not by machines directly.
# Contains: the applications both desktops use, the keyring, and the shared MIME defaults.

{
  lib,
  pkgs,
  ...
}:

{
  # Keyring for passwords and encryption keys, seahorse is used for key management.
  services.gnome.gnome-keyring.enable = true;

  # Desktop-independent applications.
  environment.systemPackages = with pkgs; [
    brasero # Disc burning application.
    evolution # Email client with calendar support.
    gparted # Gnome partition editor.
    # Collection-based music player, without the unused streaming services.
    (pkgs.strawberry.overrideAttrs (oldAttrs: {
      cmakeFlags = oldAttrs.cmakeFlags ++ [
        (lib.cmakeBool "ENABLE_SUBSONIC" false)
        (lib.cmakeBool "ENABLE_TIDAL" false)
        (lib.cmakeBool "ENABLE_SPOTIFY" false)
        (lib.cmakeBool "ENABLE_QOBUZ" false)
        (lib.cmakeBool "ENABLE_PLEX" false)
        (lib.cmakeBool "ENABLE_JELLYFIN" false)
      ];
    }))
    vlc # Universal media player.
    xarchiver # Archive manager.
  ];

  xdg.mime.enable = true;
  # Desktop-specific defaults (file manager, text editor, viewers) are declared in each desktop module.
  # Find the desktop file in nix store with: find /nix/store/ -name "*application_name*desktop"
  xdg.mime.defaultApplications = {
    "audio/aac" = "vlc.desktop";
    "audio/mpeg" = "vlc.desktop";
    "audio/ogg" = "vlc.desktop";
    "audio/flac" = "org.strawberrymusicplayer.strawberry.desktop";
    "audio/wav" = "vlc.desktop";
    "audio/webm" = "vlc.desktop";
    "application/gzip" = "xarchiver.desktop";
    "application/octet-stream" = "org.qbittorrent.qBittorrent.desktop";
    "application/x-bzip" = "xarchiver.desktop";
    "application/x-bzip2" = "xarchiver.desktop";
    "application/zip" = "xarchiver.desktop";
    "application/vnd.rar" = "xarchiver.desktop";
    "application/x-tar" = "xarchiver.desktop";
    "application/x-7z-compressed" = "xarchiver.desktop";
    "text/calendar" = "org.gnome.Evolution.desktop";
    "text/html" = "firefox-devedition.desktop";
    "video/mp4" = "vlc.desktop";
    "video/mpeg" = "vlc.desktop";
    "video/mp2t" = "vlc.desktop";
    "video/ogg" = "vlc.desktop";
    "video/vnd.avi" = "vlc.desktop";
    "video/webm" = "vlc.desktop";
    "video/x-msvideo" = "vlc.desktop";
    "video/x-matroska" = "vlc.desktop";
  };
}
