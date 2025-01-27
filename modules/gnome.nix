{ pkgs, ... }:
{
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.excludePackages = with pkgs; [
    xterm
  ];

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable gnome-keyring.
  services.gnome.gnome-keyring.enable = true;

  # Exclude unnecessary GNOME programs.
  environment.gnome.excludePackages = with pkgs; [
    gnome-photos
    geary
    gnome-music
    gnome-weather
    gnome-clocks
    cheese
    gnome-tour
    gnome-connections
    gnome-logs
    gnome-maps
  ];

  # Include gnome-packages as part of system-packages.  
  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnome-network-displays
    ghex
  ];
}