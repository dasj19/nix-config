{ config, pkgs, gitSecrets, ... }:

{
  imports = [
    ./laptop.nix
  ];

  programs.git.userName = gitSecrets.danielFullname;
  programs.git.userEmail = gitSecrets.danielWorkEmail;

}
