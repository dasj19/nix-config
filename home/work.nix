{ lib, config, pkgs, gitSecrets, ... }:

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
    "phpcs.standard" = "Drupal";
    "phpcs.executablePath" = "/home/daniel/.config/composer/vendor/bin/phpcs";
    "phpResolver.phpSnifferCommand" = "/home/daniel/.config/composer/vendor/bin/phpcs";
    "phpResolver.phpStandards" = "Drupal,DrupalPractice";
  };

}
