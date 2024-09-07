{ pkgs, ... }:

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

    # `Active gnome-extensions.
    enabled-extensions = [
      "clipboard-indicator@tudmotu.com"
    ];
  };

  programs.vscode.enable = true;
  programs.vscode.package = pkgs.vscodium;
  programs.vscode.mutableExtensionsDir = false;
  programs.vscode.extensions =  with pkgs.vscode-marketplace; with pkgs.vscode-extensions; [
    # Nix language support.
    jnoortheen.nix-ide
    # Spell checker.
    streetsidesoftware.code-spell-checker

    # At the moment Codeium is installed from the marketplace vsix file.
    # codeium.codeium does not properly work with the Nix ecosystem
    # as it requires to download the language server from github.
    codeium.codeium
  ];

  programs.vscode.userSettings = {
    # Editor settings.
    "[php]"."editor.tabSize" = 2;
    # AI Assistant.
    "codeium.enableConfig"."*" = true;
    "codeium.enableConfig"."nix" = true;
    # Spell checker.
    "cSpell.language" = "en";
    "cSpell.enabledFileTypes"."nix" = true;
    # Nix language.
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = "nil";
  };
}
