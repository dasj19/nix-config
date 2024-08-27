{ config, gitSecrets, sopsSecrets, ...}:

let

  # Git secrets.
  daniel-fullname = gitSecrets.danielFullname;

in

{
    # SOPS settings.
  sops.defaultSopsFile = sopsSecrets;
  #sops.age.generateKey = true;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # SOPS secrets.
  sops.secrets.daniel_password = {};
  sops.secrets.root_password = {};
  
  # Allow updating of password hashes.
  # Consider adopt userborn after it is merged: https://github.com/NixOS/nixpkgs/pull/332719
  #  users.mutableUsers = false;

  # Underpriviledged account.
  users.users.daniel = {
    isNormalUser = true;
    description = daniel-fullname;
    hashedPasswordFile = config.sops.secrets.daniel_password.path;
    extraGroups = [ "audio" "networkmanager" "wheel" "docker" "dialout" ];
  };
  users.users.root = {
    hashedPasswordFile = config.sops.secrets.root_password.path;
  };
}