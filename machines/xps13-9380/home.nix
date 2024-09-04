{ config, pkgs, ... }:

{
  home.username = "daniel";
  home.homeDirectory = "/home/daniel";

  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  #programs.home-manager.enable = true;
}