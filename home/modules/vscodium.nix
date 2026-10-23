# vscodium: a home manager module
# contains: vscodium with extensions and their configurations.

{
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
      # PHP.
      bmewburn.vscode-intelephense-client # cspell:disable-line

      # editorconfig support.
      editorconfig.editorconfig

      # Nix language support.
      jnoortheen.nix-ide # cspell:disable-line

      # AI agent code assistant.
      kilocode.kilo-code # cspell:disable-line

      # Editor enhancements.
      oderwat.indent-rainbow # cspell:disable-line

      # Yaml support.
      redhat.vscode-yaml

      # Spell checker.
      streetsidesoftware.code-spell-checker

      # Editor icons.
      vscode-icons-team.vscode-icons
    ]
    ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      # Twig language support.
      {
        name = "twig-language";
        publisher = "mblode"; # cspell:disable-line
        version = "0.9.4";
        hash = "sha256-TZRjodIQkgFlPlMaZs3K8Rrcl9XCUaz4/vnIaxU+SSA=";
      }
      # Symfony support.
      {
        name = "symfony-extension-pack";
        publisher = "nadim-vscode"; # cspell:disable-line
        version = "1.2.0";
        hash = "sha256-y3mkrWhlICOiFHZip3AGNDGNCvzo8FFRhhyHMu8E4yI=";
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
    "[php]"."editor.tabSize" = 2;
    "cSpell.enabledFileTypes"."nix" = true;
    "cSpell.language" = "en";
    "chat.editor.fontFamily" = "Hack Mono Nerd Font";
    "chat.editor.fontSize" = 16.0;
    "chat.fontFamily" = "UbuntuSans Nerd Font";
    "debug.console.fontFamily" = "Hack Mono Nerd Font";
    "debug.console.fontSize" = 16.0;
    "editor.allowVariableFonts" = false;
    "editor.fontFamily" = "Hack Mono Nerd Font";
    "editor.fontSize" = 16.0;
    "editor.formatOnPaste" = false;
    "editor.formatOnSave" = false;
    "editor.formatOnType" = false;
    "editor.inlayHints.fontFamily" = "Hack Mono Nerd Font";
    "editor.inlineSuggest.fontFamily" = "Hack Mono Nerd Font";
    "editor.minimap.enabled" = false;
    "editor.minimap.sectionHeaderFontSize" = 10.285714285714286;
    "kilo-code.new.agentWorkStyle" = "human-in-the-loop";
    "kilo-code.new.autocomplete.enableAutoTrigger" = false;
    "markdown.preview.fontFamily" = "UbuntuSans Nerd Font";
    "markdown.preview.fontSize" = 16.0;
    "nix.enableLanguageServer" = true;
    "nix.formatterPath" = "nixfmt";
    "notebook.markup.fontFamily" = "UbuntuSans Nerd Font";
    "scm.inputFontFamily" = "Hack Mono Nerd Font";
    "scm.inputFontSize" = 14.857142857142858;
    "screencastMode.fontSize" = 64.0;
    "terminal.integrated.commandsToSkipShell" = [
      "kilo-code.new.agentManagerOpen"
      "kilo-code.new.agentManager.showTerminal"
      "kilo-code.new.agentManager.previousTerminal"
      "kilo-code.new.agentManager.nextTerminal"
    ];
    "terminal.integrated.fontSize" = 16.0;
    "workbench.colorTheme" = "Stylix";
    "workbench.iconTheme" = "vscode-icons";
    "workbench.startupEditor" = "none";
  };
}
