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

  programs.vscode.extensions =
  let
      codium-vsix = pkgs.vscode-utils.buildVscodeMarketplaceExtension rec {
        mktplcRef = {
          name = "codeium";
          version = "1.17.1";
          publisher = "Codeium";
        };
        vsix = builtins.fetchurl {
            url = "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/Codeium/vsextensions/codeium/1.17.1/vspackage";
            sha256 = "1ds9qcp7q2a84ia78ggwshlnj988sylv8zfh9zvdhbwb77lh93v1";
          };
        language-server = builtins.fetchurl {
          url = "https://github.com/Exafunction/codeium/releases/download/language-server-v1.16.1/language_server_linux_x64";
          sha256 = "0rsrc51p4mccy4xzs4mk6x1a53ay451m7cam95kzpkva7rbk9k8p";
        };
        
        nativeBuildInputs = [ pkgs.unzip ];
        buildInputs = [ pkgs.codeium ];
        unpackPhase = ''
          runHook preUnpack
          
          mkdir -p extension/dist/40c19f24318b082e366fe4260c6c56b2316bb655
          unzip ${vsix}

          # This does not work.
          # cp ${language-server} extension/dist/40c19f24318b082e366fe4260c6c56b2316bb655/language_server_linux_x64
          # chmod +777 extension/dist/40c19f24318b082e366fe4260c6c56b2316bb655/language_server_linux_x64

          ln -s /home/daniel/system/home-manager/codium/language_server_linux_x64 extension/dist/40c19f24318b082e366fe4260c6c56b2316bb655/language_server_linux_x64
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

    # At the moment Codeium does not properly work with the Nix ecosystem
    # as it requires to download the language server from github.
    
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
