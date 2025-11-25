{ lib, pkgs, ... }:
{

  programs.uwsm.enable = true;
  programs.uwsm.waylandCompositors.hyprland = {
    binPath = "/run/current-system/sw/bin/Hyprland";
    prettyName = "Hyprland";
  };

  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  programs.hyprland.xwayland.enable = true;

  programs.hyprlock.enable = true;

  # Force electron apps to use wayland instead of X11.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Gnome's Seahorse is still needed for key management.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  services.greetd.enable = true;
  services.greetd.settings.default_session = {
    # Command to be executed by greetd.
    command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
    # Sets the default login user.
    user = "daniel";
  };

  # Improve audio performance.
  security.rtkit.enable = true;
  # Enable D-Bus for inter-process communication.
  services.dbus.enable = true;

  environment.systemPackages = with pkgs; [
    # CLI.
    playerctl
    wireplumber # PipeWire session manager.
    brightnessctl
    networkmanagerapplet

    # GUI.
    ffmpegthumbnailer # Video thumbnail generator. Used by nemo and nemo-preview.
    xapp-thumbnailers # Set of thumbnailers for various file types. Used by nemo and nemo-preview.
    xfce.tumbler # Thumbnail generator service. Used by nemo and nemo-preview.
    foot
    image-roll # Image viewer for Wayland.
    alacritty # Terminal emulator.
    nemo-with-extensions # File manager forked from nautilus with extra features.
    nemo-preview # File previews for nemo.
    pwvucontrol # Pipewire volume control.
    textadept # Lightweight text editor.
    walker
    waybar # Status bar for Wayland.
    wofi # Application launcher.
    xarchiver # Archive manager.
    xfce.orage # Calendar application.
    xreader # PDF Document viewer.

    pyprland
    hyprcursor
    hyprlock
    hypridle
    hyprpaper
    hyprshot
    hyprsunset
    hyprpolkitagent

    mission-center # Task manager and system monitor.
    resources # Task manager and resource monitor.

    strawberry # Replacement for gnome-music.
    evolution # Email client with calendar support.
    gnome-keyring # Keyring for managing passwords and encryption keys.
    vlc # Media player.
    xdg-desktop-portal-hyprland # XDG desktop portal implementation for Hyprland.
  ];

  xdg.mime.enable = true;
  # Find the desktop file in nix store with: find /nix/store/ -name "*application_name*desktop"
  xdg.mime.defaultApplications = lib.mkForce {
    "inode/directory" = "nemo.desktop";
    "audio/aac" = "vlc.desktop";
    "audio/mpeg" = "vlc.desktop";
    "audio/ogg" = "vlc.desktop";
    "audio/flac" = "org.strawberrymusicplayer.strawberry.desktop";
    "audio/wav" = "vlc.desktop";
    "audio/webm" = "vlc.desktop";
    "application/gzip" = "xarchiver.desktop";
    "application/json" = "textadept.desktop";
    "application/ld+json" = "textadept.desktop";
    "application/msword" = "onlyoffice-desktopeditors.desktop";
    "application/octet-stream" = "org.qbittorrent.qBittorrent.desktop";
    "application/pdf" = "xreader.desktop";
    "application/rtf" = "onlyoffice-desktopeditors.desktop";
    "application/x-bzip" = "xarchiver.desktop";
    "application/x-bzip2" = "xarchiver.desktop";
    "application/zip" = "xarchiver.desktop";
    "application/vnd.ms-powerpoint" = "onlyoffice-desktopeditors.desktop";
    "application/vnd.rar" = "xarchiver.desktop";
    "application/vnd.ms-excel" = "onlyoffice-desktopeditors.desktop";
    "application/x-sh" = "alacritty.desktop";
    "application/x-tar" = "xarchiver.desktop";
    "application/xml" = "textadept.desktop";
    "application/x-7z-compressed" = "xarchiver.desktop";
    "image/bmp" = "com.github.weclaw1.ImageRoll.desktop";
    "image/gif" = "com.github.weclaw1.ImageRoll.desktop";
    "image/vnd.microsoft.icon" = "com.github.weclaw1.ImageRoll.desktop";
    "image/jpeg" = "com.github.weclaw1.ImageRoll.desktop";
    "image/png" = "com.github.weclaw1.ImageRoll.desktop";
    "image/webp" = "com.github.weclaw1.ImageRoll.desktop";
    "text/calendar" = "org.gnome.Evolution.desktop";
    "text/css" = "textadept.desktop";
    "text/csv" = "textadept.desktop";
    "text/javascript" = "textadept.desktop";
    "text/html" = "firefox-devedition.desktop";
    "text/markdown" = "textadept.desktop";
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
