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

  programs.vscode.extensions =
  let
      # Manually installed extensions.
      # At the moment stock Codeium does not properly work with the Nix ecosystem
      # as it requires to download the language server from github.
      codium-vsix = pkgs.vscode-utils.buildVscodeMarketplaceExtension rec {
        mktplcRef = {
          name = "codeium";
          version = "1.21.10";
          publisher = "Codeium";
        };
        vsix = builtins.fetchurl {
            url = "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/Codeium/vsextensions/codeium/1.21.10/vspackage";
            sha256 = "0vqlc88qagd4sq8flwdvybyrrdlmmmn4crc4dqdj3fkrcfnj1m3f";
          };
        language-server = builtins.fetchurl {
          url = "https://github.com/Exafunction/codeium/releases/download/language-server-v1.16.4/language_server_linux_x64.gz";
          sha256 = "1x35l76ga4f3n73rinhfh5a6dxwz1labhw7smrw7ddzjwmhhs6m7";
        };
        
        nativeBuildInputs = [ pkgs.unzip ];
        buildInputs = [ pkgs.codeium ];
        
        unpackPhase = '' 
          runHook preUnpack
          
          mkdir -p extension/dist
          unzip ${vsix}

          # This is unpractical, a better solution is needed.
          ln -s /home/daniel/system/home-manager/codium extension/dist/b1b673a8fb8074357da4b4b8c7597b3ae37cb990
          #ls -l ${language-server}
          #gunzip -c ${language-server} > extension/dist/079ca7882d78fc474f5e3839828a14f440d448e1/language_server_linux_x64
          #chmod a+x,a+w extension/dist/079ca7882d78fc474f5e3839828a14f440d448e1/language_server_linux_x64

          runHook postUnpack
        '';
        installPhase = ''
        
        '';
      };
  in
    with pkgs.vscode-marketplace; with pkgs.vscode-extensions; [
    # Nix language support.
    jnoortheen.nix-ide

    # Spell checker.
    streetsidesoftware.code-spell-checker

    # Editor enhancements.
    oderwat.indent-rainbow

    # AI Assistant.
    codium-vsix
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
