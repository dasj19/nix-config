{ lib, gitSecrets, ... }:

{
  home.username = "daniel";
  home.homeDirectory = "/home/daniel";

  home.stateVersion = "24.05";

  # Home manager news.
  news.display = "show";

  programs.git.enable = true;
  programs.git.userName = lib.mkDefault gitSecrets.danielFullname;
  programs.git.userEmail = lib.mkDefault gitSecrets.danielPersonalEmail;
  programs.git.ignores = [
    # Ignore secret files.
    "git-crypt-key"
  ];
}
