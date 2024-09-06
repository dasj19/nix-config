{ pkgs, gitSecrets, nix-vscode-extensions, ... }:

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
    # At the moment Codeium is installed from the marketplace vsix file.
    # codeium.codeium does not properly work with the Nix ecosystem
    # as it requires to download the language server from github.
  ];

  programs.vscode.userSettings = {
    "[php]"."editor.tabSize" = 2;
    "codeium.enableConfig"."*" = true;
    "codeium.enableConfig"."nix" = true;
  };
}
