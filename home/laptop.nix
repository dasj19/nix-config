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

  programs.vscode.enable = true;
  programs.vscode.package = pkgs.vscodium;
  programs.vscode.extensions = with pkgs.vscode-extensions; [
    # Nix language support.
    jnoortheen.nix-ide
  ];

  programs.vscode.userSettings = {
    "[php]"."editor.tabSize" = 2;
  };
}
