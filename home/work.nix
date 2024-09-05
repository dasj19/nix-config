{ config, pkgs, gitSecrets, ... }:

{
  home.username = "daniel";
  home.homeDirectory = "/home/daniel";

  home.stateVersion = "24.05";

  # Home manager news.
  news.display = "show";

  programs.git.enable = true;
  # @TODO: Extend from base and override these.
  #programs.git.userName = gitSecrets.danielFullname;
  #programs.git.userEmail = gitSecrets.danielPersonalEmail;
  programs.git.ignores = [
    # ignore secret files.
    "git-crypt-key"
  ];
  programs.git.difftastic.enable = true;

  # Let Home Manager install and manage itself.
  #programs.home-manager.enable = true;
}
