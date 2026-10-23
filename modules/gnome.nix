# gnome: GNOME desktop environment configuration.
# scope: laptops
#
# Provides GNOME settings, extensions, and desktop customization.
# Importing this module selects GNOME as the desktop, including its home-manager settings.

{
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./desktop-common.nix
  ];

  # GNOME home-manager settings for every user on the machine.
  home-manager.sharedModules = [
    ./../home/modules/gnome.nix
  ];

  # GNOME display manager.
  services.displayManager.gdm.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.excludePackages = with pkgs; [
    xterm
  ];

  # Enable the GNOME Desktop Environment.
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
  security.pam.services.login.enableGnomeKeyring = true;
  # Disable PAM for GDM.
  security.pam.services.gdm.enable = false;

  services.avahi.enable = lib.mkForce false;

  # Exclude unnecessary GNOME programs.
  environment.gnome.excludePackages = with pkgs; [
    avahi # Zeroconf server, not used.
    decibels # Simple audio player, I do not need it.
    cheese # Simple webcam application, I do not need it.
    file-roller # Simple archive manager, I use xarchiver instead.
    geary # Email client, I use Evolution instead.
    gnome-backgrounds # Wallpaper manager, I declare wallpapers via stylix.
    gnome-calendar # Calendar application, I use Evolution.
    gnome-clocks # World clocks, I have no use for this.
    gnome-connections # Remote desktop client, I use Remmina.
    gnome-contacts # Contacts app, I would use Evolution if a need arises.
    gnome-logs # Log visualizer, I don't need it.
    gnome-maps # Map application, I use a website instead.
    gnome-music # Music player, I use strawberry and tauon.
    gnome-online-accounts # Online account manager, I have no use for it.
    gnome-tour # Gnome tour for beginners, I can use the help menu instead.
    gnome-weather # Weather service, I never use this.
    loupe # Photo viewer.
    orca # screen reader.
    papers # document reader. I do not need it.
    showtime # newer video player. I use vlc.
    snapshot # Simple webcam application, I do not need it.
    totem # Video player, I use vlc.
  ];

  # Include gnome-packages as part of system-packages.
  environment.systemPackages = with pkgs; [
    dconf-editor # Gnome registry editor.
    ghex # Gnome hex editor.
    gnome-network-displays # Screen sharing app for gnome.
    gnome-tweaks # Extra setting manager for gnome.
    remmina # Replacement for gnome-connections.
    # Temporary disabled until this pr is ready: https://github.com/NixOS/nixpkgs/pull/545666
    #soundconverter # Gnome app for audio file conversions.
  ];

  # GNOME-specific defaults, the shared ones are declared in desktop-common.nix.
  xdg.mime.defaultApplications = {
    "inode/directory" = "nautilus.desktop";
    "application/json" = "org.gnome.TextEditor.desktop";
    "application/ld+json" = "org.gnome.TextEditor.desktop";
    "application/msword" = "writer.desktop";
    "application/pdf" = "org.gnome.Evince.desktop";
    "application/rtf" = "writer.desktop";
    "application/vnd.ms-powerpoint" = "impress.desktop";
    "application/vnd.ms-excel" = "calc.desktop";
    "application/x-sh" = "org.gnome.Console.desktop";
    "application/xml" = "org.gnome.TextEditor.desktop";
    "image/bmp" = "org.gnome.Loupe.desktop";
    "image/gif" = "org.gnome.Loupe.desktop";
    "image/vnd.microsoft.icon" = "org.gnome.Loupe.desktop";
    "image/jpeg" = "org.gnome.Loupe.desktop";
    "image/png" = "org.gnome.Loupe.desktop";
    "image/webp" = "org.gnome.Loupe.desktop";
    "text/css" = "org.gnome.TextEditor.desktop";
    "text/csv" = "org.gnome.TextEditor.desktop";
    "text/javascript" = "org.gnome.TextEditor.desktop";
    "text/markdown" = "org.gnome.TextEditor.desktop";
  };
}
