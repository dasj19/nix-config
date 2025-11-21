{ pkgs, ... }:
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
  services.hypridle.enable = true;

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
    wireplumber
    brightnessctl
    networkmanagerapplet
    networkmanager_dmenu

    # GUI.
    kitty
    waybar
    foot
    wofi
    walker
    nautilus
    nemo
    pyprland
    #    hyprpickffer
    hyprcursor
    hyprlock
    hypridle
    hyprpaper
    hyprsunset
    hyprpolkitagent

    strawberry # Replacement for gnome-music.
    evolution # Email client with calendar support.
    gnome-keyring # Keyring for managing passwords and encryption keys.
    vlc # Media player.
    xdg-desktop-portal-hyprland
  ];

  xdg.mime.enable = true;
  # Find the desktop file in nix store with: find /nix/store/ -name "*application_name*desktop"
  xdg.mime.defaultApplications = {
    "inode/directory" = "nautilus.desktop";
    "audio/aac" = "vlc.desktop";
    "audio/mpeg" = "vlc.desktop";
    "audio/ogg" = "vlc.desktop";
    "audio/flac" = "org.strawberrymusicplayer.strawberry.desktop";
    "audio/wav" = "vlc.desktop";
    "audio/webm" = "vlc.desktop";
    "application/gzip" = "xarchiver.desktop";
    "application/json" = "org.gnome.TextEditor.desktop";
    "application/ld+json" = "org.gnome.TextEditor.desktop";
    "application/msword" = "writer.desktop";
    "application/octet-stream" = "org.qbittorrent.qBittorrent.desktop";
    "application/pdf" = "org.gnome.Evince.desktop";
    "application/rtf" = "writer.desktop";
    "application/x-bzip" = "xarchiver.desktop";
    "application/x-bzip2" = "xarchiver.desktop";
    "application/zip" = "xarchiver.desktop";
    "application/vnd.ms-powerpoint" = "impress.desktop";
    "application/vnd.rar" = "xarchiver.desktop";
    "application/vnd.ms-excel" = "calc.desktop";
    "application/x-sh" = "org.gnome.Console.desktop";
    "application/x-tar" = "xarchiver.desktop";
    "application/xml" = "org.gnome.TextEditor.desktop";
    "application/x-7z-compressed" = "xarchiver.desktop";
    "image/bmp" = "org.gnome.Loupe.desktop";
    "image/gif" = "org.gnome.Loupe.desktop";
    "image/vnd.microsoft.icon" = "org.gnome.Loupe.desktop";
    "image/jpeg" = "org.gnome.Loupe.desktop";
    "image/png" = "org.gnome.Loupe.desktop";
    "image/webp" = "org.gnome.Loupe.desktop";
    "text/calendar" = "org.gnome.Evolution.desktop";
    "text/css" = "org.gnome.TextEditor.desktop";
    "text/csv" = "org.gnome.TextEditor.desktop";
    "text/javascript" = "org.gnome.TextEditor.desktop";
    "text/html" = "firefox-devedition.desktop";
    "text/markdown" = "org.gnome.TextEditor.desktop";
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
