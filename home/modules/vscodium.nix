{ lib, pkgs, ... }:
{
  programs.vscode.enable = true;
  programs.vscode.package = pkgs.vscodium;
  programs.vscode.mutableExtensionsDir = false;

  # Extensions enabled in VS Codium.
  programs.vscode.profiles.default.extensions =
    with pkgs.vscode-extensions;
    [
      # Github Copilot.
      github.copilot

      # PHP.
      bmewburn.vscode-intelephense-client

      #Codeium.codeium
      # Nix language support.
      jnoortheen.nix-ide

      # Spell checker.
      streetsidesoftware.code-spell-checker

      # Editor enhancements.
      oderwat.indent-rainbow
    ]
    ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
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

    # Github Copilot.
    # @see https://github.com/VSCodium/vscodium/discussions/1487
    "github.copilot.enable" = {
      "*" = true;
      "markdown" = false;
      "plaintext" = false;
      "json" = false;
      "yaml" = false;
      "nix" = true;
      "shellscript" = true;
      "php" = true;
      "twig" = true;
    };
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "vscode-extension-bmewburn-vscode-intelephense-client"
      "vscode-extension-github-copilot"
    ];
}
