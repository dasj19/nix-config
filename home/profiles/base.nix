{ lib, gitSecrets, ... }:

{
  home.username = "daniel";
  home.homeDirectory = "/home/daniel";

  home.stateVersion = "24.05";

  # Home manager news.
  news.display = "show";

  programs.git.enable = true;
  programs.git.settings.user.name = lib.mkDefault gitSecrets.danielFullname;
  programs.git.settings.user.email = lib.mkDefault gitSecrets.danielPersonalEmail;
  programs.git.ignores = [
    # Do not track the following files.
    "git-crypt-key"
  ];
}
