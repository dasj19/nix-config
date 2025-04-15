{ config, pkgs, ... }:

{
  imports = [
    ./base.nix
  ];

  # Install gnome extensions.
  # To be enabled in dconf.settings.enable-extensions.
  home.packages = with pkgs.gnomeExtensions; [
    activate_gnome
    burn-my-windows
    clipboard-indicator
    desktop-cube
    kando-integration
  ];

  dconf.enable = true;
  dconf.settings."org/gnome/shell" = {
    disable-user-extensions = false;

    # Active gnome-extensions.
    # Changes take effect after restarting gnome-shell / logging out.
    enabled-extensions = [
      "activate_gnome@isjerryxiao"
      "burn-my-windows@schneegans.github.com"
      "clipboard-indicator@tudmotu.com"
      "desktop-cube@schneegans.github.com"
      "kando-integration@kando-menu.github.io"
    ];
  };

  # Setup a burn-my-windows profile.
  home.file."./.config/burn-my-windows/profiles/custom.conf".enable = true;
  home.file."./.config/burn-my-windows/profiles/custom.conf".text = ''
    [burn-my-windows-profile]
    paint-brush-enable-effect=false
    fire-enable-effect=false
    tv-enable-effect=true
  '';
  dconf.settings."org/gnome/shell/extensions/burn-my-windows" = {
    active-profile = "${config.home.homeDirectory}/.config/burn-my-windows/profiles/custom.conf";
  };

  programs.vscode.enable = true;
  programs.vscode.package = pkgs.vscodium;
  programs.vscode.mutableExtensionsDir = false;

  nixpkgs.config.allowUnfree = true;

  programs.vscode.profiles.default.extensions =
    with pkgs.vscode-marketplace; with pkgs.vscode-extensions; [
    # Nix language support.
    jnoortheen.nix-ide

    # Spell checker.
    streetsidesoftware.code-spell-checker

    # Editor enhancements.
    oderwat.indent-rainbow

  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [

    # Twig language support.
    {
      name = "twig-language";
      publisher = "mblode";
      version = "0.9.4";
      hash = "sha256-TZRjodIQkgFlPlMaZs3K8Rrcl9XCUaz4/vnIaxU+SSA=";
    }
  ];

  programs.vscode.profiles.default.userSettings = {
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
