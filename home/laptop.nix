{ config, lib, pkgs, ... }:

{
  imports = [
    ./base.nix
  ];

  # Install gnome extensions.
  # To be enabled in dconf.settings.enable-extensions.
  home.packages = with pkgs.gnomeExtensions; [
    burn-my-windows
    clipboard-indicator
    desktop-cube
    kando-integration
  ];

  dconf.enable = true;
  # Define the available keyboard layouts.
  dconf.settings."org/gnome/desktop/input-sources".sources = [
    (lib.hm.gvariant.mkTuple [ "xkb" "esrodk" ])
    (lib.hm.gvariant.mkTuple [ "xkb" "es" ])
    (lib.hm.gvariant.mkTuple [ "xkb" "us" ])
    (lib.hm.gvariant.mkTuple [ "xkb" "ro" ])
  ];

  # Display battery percentage on the top bar,
  dconf.settings."org/gnome/desktop/interface".show-battery-percentage = true;
  dconf.settings."org/gnome/shell" = {
    disable-user-extensions = false;

    # Active gnome-extensions.
    # Changes take effect after restarting gnome-shell / logging out.
    enabled-extensions = [
      "burn-my-windows@schneegans.github.com"
      "clipboard-indicator@tudmotu.com"
      "desktop-cube@schneegans.github.com"
      "kando-integration@kando-menu.github.io"
    ];
  };

  home.file."./.config/shell_gpt/.sgptrc".enable = true;
  home.file."./.config/shell_gpt/.sgptrc".text = ''
    DEFAULT_MODEL=ollama/deepseek-coder
    USE_LITELLM=true

    CHAT_CACHE_PATH=/tmp/chat_cache
    CACHE_PATH=/tmp/cache
    CHAT_CACHE_LENGTH=100
    CACHE_LENGTH=100
    REQUEST_TIMEOUT=60
    DEFAULT_COLOR=magenta
    ROLE_STORAGE_PATH=${config.home.homeDirectory}/.config/shell_gpt/roles
    DEFAULT_EXECUTE_SHELL_CMD=false
    DISABLE_STREAMING=false
    CODE_THEME=dracula
    OPENAI_FUNCTIONS_PATH=${config.home.homeDirectory}/.config/shell_gpt/functions
    OPENAI_USE_FUNCTIONS=true
    SHOW_FUNCTIONS_OUTPUT=false
    API_BASE_URL=default
    PRETTIFY_MARKDOWN=true
    SHELL_INTERACTION=true
    OS_NAME=auto
    SHELL_NAME=auto
    OPENAI_API_KEY=ollama
  '';

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

  programs.vscode.profiles.default.extensions =
    with pkgs.vscode-extensions; [
    # PHP.
    bmewburn.vscode-intelephense-client

    #Codeium.codeium
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
    {
      name = "symfony-extension-pack";
      publisher = "nadim-vscode";
      version = "1.2.0";
      hash = "sha256-y3mkrWhlICOiFHZip3AGNDGNCvzo8FFRhhyHMu8E4yI=";
    }
    {
      name = "php-intellisense";
      publisher = "felixfbecker";
      version = "2.3.14";
      hash = "sha256-N5il3hFytYA4dzV9AFfj4SnY2CuPvgtTrijHd6AHXKY=";
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

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "vscode-extension-bmewburn-vscode-intelephense-client"
  ];
}
