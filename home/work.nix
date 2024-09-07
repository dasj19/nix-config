{ lib, config, pkgs, gitSecrets, ... }:

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

  programs.vscode.userSettings = {
    # If it complains about read-only settings.js check: https://github.com/nix-community/home-manager/issues/1800
    "github.copilot.enable" = {
      "*" = true;
      "plaintext" = false;
      "markdown" = false;
      "scminput" = false;
    };
    "php.format.codeStyle" = "Drupal";
    "phpcs.standard" = phpStandards;
    "phpcs.executablePath" = "/home/daniel/.config/composer/vendor/bin/phpcs";
    "phpResolver.phpSnifferCommand" = "/home/daniel/.config/composer/vendor/bin/phpcs";
    "phpResolver.phpStandards" = phpStandards;
  };

}
