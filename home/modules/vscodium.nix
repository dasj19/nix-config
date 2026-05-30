# vscodium: a home manager module
# contains: vscodium with extensions and their configurations.

{
  lib,
  pkgs,
  ...
}:

{
  programs.vscodium.enable = true;
  programs.vscodium.mutableExtensionsDir = false;

  # Extensions enabled in VS Codium.
  programs.vscodium.profiles.default.extensions =
    with pkgs.vscode-extensions;
    [
      # Open source AI remote+local coding agent.
      continue.continue

      # PHP.
      bmewburn.vscode-intelephense-client # cspell:disable-line

      # Nix language support.
      jnoortheen.nix-ide

      # Yaml support.
      redhat.vscode-yaml

      # Spell checker.
      streetsidesoftware.code-spell-checker

      # Editor enhancements.
      oderwat.indent-rainbow

      # Editor icons.
      vscode-icons-team.vscode-icons

      # Git blame annotations.
      waderyan.gitblame # cspell:disable-line
    ]
    ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      # Twig language support.
      {
        name = "twig-language";
        publisher = "mblode";
        version = "0.9.4";
        hash = "sha256-TZRjodIQkgFlPlMaZs3K8Rrcl9XCUaz4/vnIaxU+SSA=";
      }
      # Symfony support.
      {
        name = "symfony-extension-pack";
        publisher = "nadim-vscode";
        version = "1.2.0";
        hash = "sha256-y3mkrWhlICOiFHZip3AGNDGNCvzo8FFRhhyHMu8E4yI=";
      }
      # PHP IDE support.
      {
        name = "php-intellisense";
        publisher = "felixfbecker";
        version = "2.3.14";
        hash = "sha256-N5il3hFytYA4dzV9AFfj4SnY2CuPvgtTrijHd6AHXKY=";
      }
      # PHP code formatter.
      {
        name = "pretty-php";
        # cspell:disable-next-line
        publisher = "lkrms";
        version = "0.4.95";
        hash = "sha256-OgyuWv60Pseq8iFKOZ+9/fOaRYY1OQKoijpPwj3SFus=";
      }
    ];

  programs.vscodium.profiles.default.userSettings = {
    # Disable editor minimap.
    "editor.minimap.enabled" = false;
    # Startup empty.
    "workbench.startupEditor" = "none";
    # Set default tab size.
    "[php]"."editor.tabSize" = 2;

    # Spell checker.
    "cSpell.language" = "en";
    "cSpell.enabledFileTypes"."nix" = true;

    # Nix language.
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = "nil";
    "nix.formatterPath" = "nixfmt";

    # Autoformat Nix files on save.
    "editor.formatOnSave" = true;
    "editor.formatOnType" = false;
    "editor.formatOnPaste" = false;

    # Set icon and color themes.
    "workbench.iconTheme" = "vscode-icons";
    "workbench.colorTheme" = "Stylix";

    # Font settings.
    "editor.allowVariableFonts" = false;
  };

  # Allowed non-free packages.
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      # Unclear why this is marked as non-free. @todo: check upstream.
      # cspell:disable-next-line
      "vscode-extension-bmewburn-vscode-intelephense-client"
    ];
}
