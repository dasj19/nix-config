# hyprland: module to configure system-wide hyprland.
# scope: laptops
# contains: desktop environment packages and customizations.
# Importing this module selects Hyprland as the desktop, including its home-manager settings.

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./desktop-common.nix
  ];

  # Hyprland home-manager settings for every user on the machine.
  home-manager.sharedModules = [
    ./../home/modules/hyprland.nix
    ./../home/modules/hyprlock.nix
    ./../home/modules/waybar.nix
  ];

  # Universal Wayland Session Manager.
  programs.uwsm.enable = true;

  # hyprland settings.
  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  programs.hyprland.xwayland.enable = true;

  programs.hyprlock.enable = true;
  # hyprlock reads fingerprints itself, pam_fprintd would compete with it for the reader.
  security.pam.services.hyprlock.fprintAuth = false;

  # Icon theme for GTK and Qt apps, unlike GNOME there is none by default.
  stylix.icons.enable = true;
  stylix.icons.package = pkgs.papirus-icon-theme;
  stylix.icons.dark = "Papirus-Dark";
  stylix.icons.light = "Papirus-Light";

  # Force electron apps to use wayland instead of X11.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Unlock the keyring (enabled in desktop-common.nix) at login.
  security.pam.services.hyprland.enableGnomeKeyring = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # greetd settings.
  # Hyprland is started by uwsm as a systemd user service, its output goes to the journal.
  services.greetd.enable = true;
  # Auto-login the main user once at boot, as a regular session that logind can lock.
  services.greetd.settings.initial_session = {
    # uwsm also logs to the journal, so its text on the console is thrown away.
    command = "uwsm start hyprland-uwsm.desktop >/dev/null 2>&1";
    user = config.users.primaryUser;
  };
  # Login prompt shown after logging out.
  services.greetd.settings.default_session.command = lib.concatStringsSep " " [
    "${pkgs.tuigreet}/bin/tuigreet"
    "--time"
    "--asterisks"
    "--cmd 'uwsm start hyprland-uwsm.desktop'"
  ];
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
    ffmpegthumbnailer # Video thumbnail generator. Used by nemo and nemo-preview.
    foot # Wayland terminal emulator.
    image-roll # Image viewer for Wayland.
    mpv # alternative vide player.
    nemo-preview # File previews for nemo.
    nemo-with-extensions # File manager forked from nautilus with extra features.
    orage # Calendar application.
    pwvucontrol # Pipewire volume control.
    textadept # Lightweight text editor.
    tumbler # Thumbnail generator service. Used by nemo and nemo-preview.
    wl-mirror # Screen mirroring utility.
    wofi # Application launcher.
    xapp-thumbnailers # Set of thumbnailers for various file types. Used by nemo and nemo-preview.
    (pkgs.callPackage ../pkgs/clipvault.nix { }) # Clipboard history manager for Wayland.

    hyprcursor # Cursor manager for hyprland.
    hypridle # Manages idle settings.
    hyprlock # Manages the screen lock.
    hyprmon # TUI to manage monitors.
    hyprpaper # Deals with wallpapers.
    hyprshot # Takes screenshots.
    nwg-displays # GUI to manage monitors.
    pyprland # Plugin manager for hyprland.
    wlr-layout-ui # GUI for managing monitor layouts in Wayland.

    gnome-contacts # Contact manager.
    gnome-keyring # Keyring for managing passwords and encryption keys.
    kdePackages.kwindowsystem # Wayland plugin for KWindowSystem, used by the kvantum Qt style.
    lm_sensors # Tools for reading hardware sensors.
    mission-center # Task manager and system monitor.
    resources # Task manager and resource monitor.
    showmethekey # OSD of pressed keys.
    swayosd # Controls media keys and special keys with visuals.
    # @TODO revert to tauon once it is fixed upstream. https://github.com/NixOS/nixpkgs/issues/577587
    tauon # Album-based with lyrics support.
    tofi # wayland-native dynamic menu.
  ];

  # Mediator for access to system resources (file choosers, screenshots, etc).
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk # To support GTK apps under Wayland.
    xdg-desktop-portal-hyprland # XDG desktop portal implementation for Hyprland.
  ];

  # Hyprland-specific defaults, the shared ones are declared in desktop-common.nix.
  xdg.mime.defaultApplications = {
    "inode/directory" = "nemo.desktop";
    "application/json" = "textadept.desktop";
    "application/ld+json" = "textadept.desktop";
    "application/msword" = "euro-office-desktopeditors.desktop";
    "application/pdf" = "atril.desktop";
    "application/rtf" = "euro-office-desktopeditors.desktop";
    "application/vnd.ms-powerpoint" = "euro-office-desktopeditors.desktop";
    "application/vnd.mozilla.xul+xml" = "firefox-devedition.desktop";
    "application/vnd.ms-excel" = "euro-office-desktopeditors.desktop";
    "application/x-sh" = "alacritty.desktop";
    "application/xml" = "textadept.desktop";
    "application/xhtml+xml" = "firefox-devedition.desktop";
    "image/bmp" = "com.github.weclaw1.ImageRoll.desktop";
    "image/gif" = "com.github.weclaw1.ImageRoll.desktop";
    "image/vnd.microsoft.icon" = "com.github.weclaw1.ImageRoll.desktop";
    "image/jpeg" = "com.github.weclaw1.ImageRoll.desktop";
    "image/png" = "com.github.weclaw1.ImageRoll.desktop";
    "image/webp" = "com.github.weclaw1.ImageRoll.desktop";
    "text/css" = "textadept.desktop";
    "text/csv" = "textadept.desktop";
    "text/javascript" = "textadept.desktop";
    "text/markdown" = "textadept.desktop";
    "text/plain" = "textadept.desktop";
    "text/xml" = "textadept.desktop";
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
