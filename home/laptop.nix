{ config, pkgs, gitSecrets, ... }:

{
  imports = [
    ./base.nix
  ];

  home.packages = with pkgs; [
    gnomeExtensions.clipboard-indicator
  ];

  dconf.enable = true;
  dconf.settings."org/gnome/shell" = {
    disable-user-extensions = false;

    # `gnome-extensions list` for a list
    enabled-extensions = [
      "clipboard-indicator@tudmotu.com"
    ];
  };
}