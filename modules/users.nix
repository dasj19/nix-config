# users: user account and password management.
# scope: all machines

{
  config,
  gitSecrets,
  pkgs,
  sopsSecrets,
  ...
}:

let
  # Git secrets.
  daniel-fullname = gitSecrets.danielFullname;
in

{
  # Required packages.
  environment.systemPackages = with pkgs; [
    sops
  ];

  # SOPS settings.
  sops.defaultSopsFile = sopsSecrets;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # SOPS secrets.
  # Password hashes are decrypted to /run/secrets-for-users, before the users are created.
  sops.secrets.daniel_password.neededForUsers = true;
  sops.secrets.root_password.neededForUsers = true;

  # Allow updating of password hashes.
  users.mutableUsers = true;

  # Create users with userborn instead of the perl script.
  services.userborn.enable = true;

  # Underprivileged account.
  users.users.${config.users.primaryUser} = {
    isNormalUser = true;
    description = daniel-fullname;
    hashedPasswordFile = config.sops.secrets.daniel_password.path;
    extraGroups = [
      "audio"
      "dialout"
      "docker"
      "lp"
      "networkmanager"
      "scanner"
      "tty" # Needed to allow serial console connections (Charachorder) in Chromium.
      "video"
      "wheel"
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
}
