{
  awesome-linux-templates,
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

  # Install libreoffice impress templates at the default template path.
  home.file."libreoffice-impress-templates" = {
    target = "./.config/libreoffice/4/user/template";
    source = "${pkgs.callPackage ../pkgs/libreoffice-impress-templates.nix { }}";
    recursive = true;
  };
}
