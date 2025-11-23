{ pkgs, gitSecrets, ... }:

let
  phpStandards = "Drupal,DrupalPractice,SlevomatCodingStandard,VariableAnalysis";
in

{
  imports = [
    ./laptop.nix
  ];

  programs.git.userName = gitSecrets.danielFullname;
  programs.git.userEmail = gitSecrets.danielWorkEmail;

  programs.fish.enable = true;
  programs.fish.interactiveShellInit = ''
    set PATH $PATH $HOME/.config/composer/vendor/bin
  '';

  programs.vscode.profiles.default.extensions =
  let
      # Old drupal syntax highlight extension that still does its job.
      vs-code-drupal-vsix = pkgs.vscode-utils.buildVscodeMarketplaceExtension rec {
        mktplcRef = {
          name = "vs-code-drupal";
          version = "0.0.12";
          publisher = "marcostazi";
        };
        vsix = builtins.fetchurl {
          url = "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/marcostazi/vsextensions/VS-code-drupal/0.0.12/vspackage";
          sha256 = "18vghvx9m7lik2rndmwm4xfw3sz7gmgpkzj2irbl6hylyqagpcmh";
        };
        
        unpackPhase = ''
          runHook preUnpack
          unzip ${vsix}
          runHook postUnpack
        '';
      };
  in
  
  with pkgs.vscode-marketplace; with pkgs.vscode-extensions; [
    # AI assistant.
    github.copilot

    # Cross-language debugging.
    formulahendry.code-runner

    # Drupal syntax highlighter.
    vs-code-drupal-vsix

    # Git enhancements.
    waderyan.gitblame

    # Language support.
    redhat.vscode-yaml

    # PHP helpers.
    bmewburn.vscode-intelephense-client
    devsense.composer-php-vscode

    # Templating.
    mblode.twig-language
  ];

  programs.vscode.profiles.default.userSettings = {
    # If it complains about read-only settings.js check: https://github.com/nix-community/home-manager/issues/1800
    "github.copilot.enable" = {
      "*" = true;
      "plaintext" = false;
      "markdown" = false;
      "scminput" = false;
    };
    "php.format.codeStyle" = "Drupal";
    "phpcs.enable" = true;
    "phpcs.standard" = phpStandards;
    "phpcs.executablePath" = "/home/daniel/.config/composer/vendor/bin/phpcs";
    "phpResolver.phpSnifferCommand" = "/home/daniel/.config/composer/vendor/bin/phpcs";
    "phpResolver.phpStandards" = phpStandards;
  };

}
