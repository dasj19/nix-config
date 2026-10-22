# hyprland: module to configure system-wide hyprland.
# scope: laptops
# contains: desktop environment packages and customizations.

{
  lib,
  pkgs,
  ...
}:

{
  # Universal Wayland Session Manager.
  programs.uwsm.enable = true;

  # hyprland settings.
  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  programs.hyprland.xwayland.enable = true;

  programs.hyprlock.enable = true;

  # Force electron apps to use wayland instead of X11.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Gnome's seahorse is still needed for key management.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.hyprland.enableGnomeKeyring = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # greetd settings.
  services.greetd.enable = true;
  services.greetd.settings.default_session = {
    # Start hyprland throwing all text output away.
    command = "start-hyprland &>/dev/null";
    # Auto-login user.
    user = "daniel";
  };
  # Improve audio performance.
  security.rtkit.enable = true;
  # Enable D-Bus for inter-process communication.
  services.dbus.enable = true;
  # Gnome's virtual filesystem.
  services.gvfs.enable = true;

  environment.systemPackages = with pkgs; [
    # CLI.
    brightnessctl # Controls brightness levels from CLI.
    networkmanagerapplet # Small network manager application.
    playerctl # Controls media players from CLI.
    wireplumber # PipeWire session manager.
    wl-clipboard # Clipboard utilities for Wayland.

    # GUI.
    alacritty # Terminal emulator.
    atril # PDF Document viewer.
    baobab # Disc usage analyzer.
    brasero # Disc burning utility.
    ffmpegthumbnailer # Video thumbnail generator. Used by nemo and nemo-preview.
    foot # Wayland terminal emulator.
    image-roll # Image viewer for Wayland.
    mako # Notification daemon for Wayland.
    mpv # alternative vide player.
    nemo-preview # File previews for nemo.
    nemo-with-extensions # File manager forked from nautilus with extra features.
    orage # Calendar application.
    pwvucontrol # Pipewire volume control.
    textadept # Lightweight text editor.
    tumbler # Thumbnail generator service. Used by nemo and nemo-preview.
    waybar # Status bar for Wayland.
    wl-mirror # Screen mirroring utility.
    wofi # Application launcher.
    xapp-thumbnailers # Set of thumbnailers for various file types. Used by nemo and nemo-preview.
    xarchiver # Archive manager.
    (pkgs.callPackage ../pkgs/clipvault.nix { }) # Clipboard history manager for Wayland.

    hyprcursor # Cursor manager for hyprland.
    hypridle # Manages idle settings.
    hyprlock # Manages the screen lock.
    hyprmon # TUI to manage monitors.
    hyprpaper # Deals with wallpapers.
    hyprpolkitagent # Agent to request elevated privileges.
    hyprshot # Takes screenshots.
    nwg-displays # GUI to manage monitors.
    pyprland # Plugin manager for hyprland.
    wlr-layout-ui # GUI for managing monitor layouts in Wayland.

    evolution # Email client with calendar support.
    gnome-contacts # Contact manager.
    gnome-keyring # Keyring for managing passwords and encryption keys.
    gparted # Gnome partition editor.
    lm_sensors # Tools for reading hardware sensors.
    mission-center # Task manager and system monitor.
    resources # Task manager and resource monitor.
    showmethekey # OSD of pressed keys.
    strawberry # Collection-based music player.
    swayosd # Controls media keys and special keys with visuals.
    tauon # Album-based with lyrics support.
    tofi # wayland-native dynamic menu.
    vlc # Universal media player.
  ];

  # Mediator for access to system resources (file choosers, screenshots, etc).
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk # To support GTK apps under Wayland.
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
    "application/msword" = "euro-office-desktopeditors.desktop";
    "application/octet-stream" = "org.qbittorrent.qBittorrent.desktop";
    "application/pdf" = "atril.desktop";
    "application/rtf" = "euro-office-desktopeditors.desktop";
    "application/x-bzip" = "xarchiver.desktop";
    "application/x-bzip2" = "xarchiver.desktop";
    "application/zip" = "xarchiver.desktop";
    "application/vnd.ms-powerpoint" = "euro-office-desktopeditors.desktop";
    "application/vnd.rar" = "xarchiver.desktop";
    "application/vnd.mozilla.xul+xml" = "firefox-devedition.desktop";
    "application/vnd.ms-excel" = "euro-office-desktopeditors.desktop";
    "application/x-sh" = "alacritty.desktop";
    "application/x-tar" = "xarchiver.desktop";
    "application/xml" = "textadept.desktop";
    "application/xhtml+xml" = "firefox-devedition.desktop";
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
    "text/plain" = "textadept.desktop";
    "text/xml" = "textadept.desktop";
    "video/mp4" = "vlc.desktop";
    "video/mpeg" = "vlc.desktop";
    "video/mp2t" = "vlc.desktop";
    "video/ogg" = "vlc.desktop";
    "video/vnd.avi" = "vlc.desktop";
    "video/webm" = "vlc.desktop";
    "video/x-msvideo" = "vlc.desktop";
    "video/x-matroska" = "vlc.desktop";
    "x-scheme-handler/http" = "firefox-devedition.desktop";
    "x-scheme-handler/https" = "firefox-devedition.desktop";
  };

  # Gnome's policy kit.
  security.wrappers.pkexec.enable = lib.mkForce true;
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
