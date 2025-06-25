{ pkgs, ... }:
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

    # Enable gnome-keyring.
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.login.enableGnomeKeyring = true;
    # Disable PAM for GDM.
    security.pam.services.gdm.enable = false;

    # Exclude unnecessary GNOME programs.
    environment.gnome.excludePackages = with pkgs; [
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
      evolution               # Replacement for geary and gnome-calendar.
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
    xdg.mime.defaultApplications = {
      "application/pdf" = "org.gnome.Evince.desktop";
      "application/zip" = "peazip.desktop";
      "application/json" = "org.gnome.TextEditor.desktop";
      "video/mp4" = "vlc.desktop";
      "video/mp2t" = "vlc.desktop";
      "video/vnd.avi" = "vlc.desktop";
      "video/webm" = "vlc.desktop";
      "video/x-matroska" = "vlc.desktop";
    };
  };
}