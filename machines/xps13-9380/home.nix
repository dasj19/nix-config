{ config, pkgs, gitSecrets, ... }:

{
  home.username = "daniel";
  home.homeDirectory = "/home/daniel";

  home.stateVersion = "24.05";

  # Home manager news.
  news.display = "show";

  programs.git.enable = true;
  programs.git.userName = gitSecrets.danielFullname;
  programs.git.userEmail = gitSecrets.danielPersonalEmail;

  # Let Home Manager install and manage itself.
  #programs.home-manager.enable = true;
}