{ awesome-linux-templates, config, lib, pkgs, ... }:

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

  # Media shortcuts. Using Ctrl instead of Fn (controlled by ACPI).
  # https://heywoodlh.io/nixos-gnome-settings-and-keyboard-shortcuts
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys" = {
    next = [ "<Ctrl>right" ];
    previous = [ "<Ctrl>left" ];
    play = [ "<Ctrl>masculine" ];
  };

  dconf.settings."org/gnome/desktop/interface" = {
    # Display the weekday in the date close to the clock.
    clock-show-weekday = true;
    # Disable the default hot-corners.
    enable-hot-corners = false;
    # Display battery percentage on the top bar.
    show-battery-percentage = true;
    # Set text scaling below 100%.
    text-scaling-factor = 0.90;
    toolbar-icons-size = "small";
  };
  dconf.settings."org/gnome/desktop/notifications" = {
    # Disable notifications in the lock screen.
    show-in-lock-screen = false;
  };
  # Accessibility.
  dconf.settings."org/gnome/desktop/a11y" = {
    # Disable notifications in the lock screen.
    always-show-universal-access-status = true;
  };
  # Display week date (week number) in the top bar calendar.
  dconf.settings."org/gnome/desktop/calendar".show-weekdate = true;
  # Allow visual bell.
  dconf.settings."org/gnome/desktop/wm/preferences".visual-bell = true;
  # Gnome extensions.
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

  # Extensions enabled in VS Codium.
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
    # Set default tab size.
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

  # Add Kando to the list of autostart programs.
  xdg.configFile."autostart/kando.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Exec=kando
    Name=Kando Autostart
  '';

  # Populate linux user templates.
  home.file."awesome-linux-templates" = {
    target = "./system/templates";
    source = "${awesome-linux-templates}/templates";
    recursive = true;
  };
}
