{ config, lib, pkgs, ... }:

let
  variables = import ./secrets/variables.nix;
in

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Include email-related software configuration.
      ./email.nix
      # Agenix secret management tool.
      "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/modules/age.nix"
    ];

  # Files that holds the secrets.
  age.secrets.cloudflare-dns-api-credentials.file = ./secrets/cloudflare-dns-api-credentials.age;
  # File containing the following variables.
  # CLOUDFLARE_EMAIL=
  # CF_DNS_API_TOKEN=
  # CF_ZONE_API_TOKEN=
  age.secrets.mailserver-account-daniel-password.file = ./secrets/mailserver-account-daniel-password.age;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "contabo2";

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # Font and keymap for the console.
  console = {
    font = "Lat2-Terminus16";
    keyMap = "es";
  };

  # Unpriviledged user account.
  users.users.daniel = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  # System-wide packages.
  environment.systemPackages = with pkgs; [
     # CLI.
     git
     wget
  ] ++ [ (pkgs.callPackage "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/pkgs/agenix.nix" {}) ];

  # List services.

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  services.logrotate.checkConfig = false;

  # Enable fish as the default shell.
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Fish shell customizations.
  programs.fish.interactiveShellInit = ''
    # Forcing true color in the terminals.
    set -g fish_term24bit 1
    # Empty fish greeting. @TODO: consider making it a nix option for fish.
    set -g fish_greeting ""
    # Add custom message to the fish prompt.
    echo 'CONTABO _2_'
  '';


  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22  # OpenSSH
  ];
  networking.firewall.allowedUDPPorts = [

  ];

  # ACME settings.
  security.acme.acceptTerms = true;
  security.acme.defaults.email = variables.webmasterEmail;
  security.acme.defaults.dnsProvider = "cloudflare";
  security.acme.defaults.credentialsFile = config.age.secrets.cloudflare-dns-api-credentials.path;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix).
  system.copySystemConfiguration = true;

  # Custom shell aliases.
  environment.shellAliases = {
    # Includes the path to the nixpkgs fork to pickup our own updates.
    nixos-rebuild = "nixos-rebuild -I nixpkgs=/root/workspace/nixpkgs --log-format bar-with-logs --keep-going";
  };

  # Initial version. Consult manual before changing.
  system.stateVersion = "24.05";

}

