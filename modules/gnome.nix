{ lib, pkgs, ... }:
{
  config = {
    # Enable the X11 windowing system.
    services.xserver.enable = true;
    services.xserver.excludePackages = with pkgs; [
      xterm
    ];

    # Enable the GNOME Desktop Environment.
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    # Used to generate thumbnails.
    services.gnome.sushi.enable = true;
    # UPnP media server.
    services.gnome.rygel.enable = false;
    # Local search services.
    services.gnome.localsearch.enable = true;
    services.gnome.tinysparql.enable = true;
    # User-level file sharing service.
    services.gnome.gnome-user-share.enable = false;
    # The UI that facilitates changing gnome settings.
    services.gnome.gnome-settings-daemon.enable = true;
    # Remote desktop support.
    services.gnome.gnome-remote-desktop.enable = false;
    # Online accounts service.
    services.gnome.gnome-online-accounts.enable = false;
    # The gnome tour.
    services.gnome.gnome-initial-setup.enable = false;
    # Gnome browser integrations.
    # Used mostly to install gnome extensions from a browser.
    services.gnome.gnome-browser-connector.enable = false;
    # Developer friendly network integration for glib.
    services.gnome.glib-networking.enable = lib.mkForce false;
    # Google Container Registry SSH agent.
    services.gnome.gcr-ssh-agent.enable = false;
    # Gnome games collection.
    services.gnome.games.enable = false;
    # Provides data storage facilities for evolution.
    services.gnome.evolution-data-server.enable = true;
    # Core Gnome Shell applications and technologies.
    services.gnome.core-apps.enable = true;
    services.gnome.core-os-services.enable = true;
    services.gnome.core-shell.enable = true;
    # Gnome essential development tools.
    services.gnome.core-developer-tools.enable = false;
    # Assistive technologies.
    services.gnome.at-spi2-core.enable = true;
    # Enable gnome-keyring.
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.login.enableGnomeKeyring = true;
    # Disable PAM for GDM.
    security.pam.services.gdm.enable = false;

    services.avahi.enable = lib.mkForce false;

    # Exclude unnecessary GNOME programs.
    environment.gnome.excludePackages = with pkgs; [
      avahi                   # Zeroconf server, not used.
      decibels                # Simple audio player, I do not need it.
      cheese                  # Simple webcam application, I do not need it.
      file-roller             # Simple archive manager, I use peazip instead.
      geary                   # Email client, I use Evolution instead.
      gnome-backgrounds       # Wallpaper manager, I declare wallpapers via stylix.
      gnome-calendar          # Calendar application, I use Evolution.
      gnome-clocks            # World clocks, I have no use for this.
      gnome-connections       # Remote desktop client, I use Remmina.
      gnome-contacts          # Contacts app, I would use Evolution if a need arises.
      gnome-logs              # Log visualizer, I don't need it.
      gnome-maps              # Map application, I use a website instead.
      gnome-music             # Music player, I use strawberry and tauon.
      gnome-online-accounts   # Online account manager, I have no use for it.
      gnome-photos            # Advanced photo organizer, does much more than I need.
      gnome-tour              # Gnome tour for beginners, I can use the help menu instead.
      gnome-weather           # Weather service, I never use this.
      snapshot                # Simple webcam application, I do not need it.
      totem                   # Video player, I use vlc.
    ];

    # Include gnome-packages as part of system-packages.  
    environment.systemPackages = with pkgs; [
      brasero                 # Disc burning application.
      dconf-editor            # Gnome registry editor.
      evolutionWithPlugins    # Replacement for geary and gnome-calendar.
      ghex                    # Gnome hex editor.
      gnome-tweaks            # Extra setting manager for gnome.
      gnome-network-displays  # Screen sharing app for gnome.
      gparted                 # Gnome partition editor.
      meld                    # Diff manager and editor.
      peazip                  # Replacement for file-roller.
      remmina                 # Replacement for gnome-connections.
      strawberry              # Replacement for gnome-music.
      tauon                   # Replacement for gnome-music with lyrics support.
      vlc                     # Replacement for totem.
    ];

    xdg.mime.enable = true;
    # Find the desktop file in nix store with: find /nix/store/ -name "*application_name*desktop"
    xdg.mime.defaultApplications = {
      "audio/mpeg"                = "vlc.desktop";
      "audio/ogg"                 = "vlc.desktop";
      "audio/flac"                = "org.strawberrymusicplayer.strawberry.desktop";
      "application/gzip"          = "peazip.desktop";
      "application/json"          = "org.gnome.TextEditor.desktop";
      "application/octet-stream"  = "org.qbittorrent.qBittorrent.desktop";
      "application/pdf"           = "org.gnome.Evince.desktop";
      "application/x-bzip"        = "peazip.desktop";
      "application/x-bzip2"       = "peazip.desktop";
      "application/zip"           = "peazip.desktop";
      "image/jpeg"                = "org.gnome.Loupe.desktop";
      "image/png"                 = "org.gnome.Loupe.desktop";
      "text/css"                  = "org.gnome.TextEditor.desktop";
      "text/csv"                  = "org.gnome.TextEditor.desktop";
      "video/mp4"                 = "vlc.desktop";
      "video/mp2t"                = "vlc.desktop";
      "video/vnd.avi"             = "vlc.desktop";
      "video/webm"                = "vlc.desktop";
      "video/x-matroska"          = "vlc.desktop";
    };
  };
}