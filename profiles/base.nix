{ pkgs, ...}:
{
  imports = [
    ./../modules/aliases.nix
    ./../modules/fish.nix
    ./../modules/folders.nix
    ./../modules/keyboard.nix
    ./../modules/locale.nix
    ./../modules/nix.nix
    ./../modules/starship.nix
    ./../modules/stylix.nix
    ./../modules/users.nix
  ];

  # Base packages are a must for every machine.
  # These should be CLI-only packages.
  environment.systemPackages = with pkgs; [
    # CLI.
    bat
    cpufrequtils
    eza
    git
    jq
    lf
    lsof
    lshw
    legit
    ncdu
    nmap
    screen
    smartmontools
    tree
    wget

    # Encryption.
    age
    git-crypt
    sops
  ];
}
