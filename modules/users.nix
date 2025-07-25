{ config, gitSecrets, sopsSecrets, pkgs, ...}:

let

  # Git secrets.
  daniel-fullname = gitSecrets.danielFullname;

in

{
  config = {
    # Required packages.
    environment.systemPackages = with pkgs; [
      sops
    ];

    # SOPS settings.
    sops.defaultSopsFile = sopsSecrets;
    #sops.age.generateKey = true;
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";

    # SOPS secrets.
    sops.secrets.daniel_password = {};
    sops.secrets.root_password = {};
    
    # Allow updating of password hashes.
    # Consider adopt userborn after it is merged: https://github.com/NixOS/nixpkgs/pull/332719
    users.mutableUsers = true;

    # Underprivileged account.
    users.users.daniel = {
      isNormalUser = true;
      description = daniel-fullname;
      hashedPasswordFile = config.sops.secrets.daniel_password.path;
      extraGroups = [
        "audio"
        "video"
        "networkmanager"
        "wheel"
        "docker"
        "dialout"
        "scanner"
        "lp"
      ];
    };
    users.users.root = {
      hashedPasswordFile = config.sops.secrets.root_password.path;
    };

    # Use sudo-rs instead of sudo.
    security.sudo.enable = false;
    security.sudo-rs.enable = true;
    security.sudo-rs.extraConfig = ''
      # Increase the password ask timeout to 60 minutes.
      Defaults timestamp_timeout=60
    '';
  };
  
}
