{
  awesome-linux-templates,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./base.nix
    # Home modules.
    ../modules/gnome.nix # @todo Remove when not using Gnome.
    ../modules/hyprland.nix
    ../modules/hyprlock.nix
    ../modules/shellgpt.nix
    ../modules/vscodium.nix
    ../modules/waybar.nix
  ];

  # HM installs and manages itself.
  programs.home-manager.enable = true;

  # Notification daemon for wayland.
  services.mako.enable = true;
  services.mako.settings.default-timeout = 5000;

  # Populate linux user templates.
  home.file."awesome-linux-templates" = {
    target = "./system/templates";
    source = "${awesome-linux-templates}/templates";
    recursive = true;
  };
}
