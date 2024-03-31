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
      # Include the wordpress web sites.
      ./wordpress.nix
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

  # Host and network settings.
  networking.enableIPv6  = true;
  networking.hostName = "linodenix2";
  networking.networkmanager.enable = false;
  networking.usePredictableInterfaceNames = false;
  networking.tempAddresses = "enabled";  
  networking.useDHCP = true;

  # Open ports in the firewall.
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    25   # SMTP
    53   # DNS
    80   # HTTP (for signing acme certificates)
    143  # IMAP
    443  # HTTPS
    465  # SMTP over TLS
    993  # IMAP over TLS
    2202 # SSH - OpenSSH
  ];
  networking.firewall.allowedUDPPorts = [
    53   # DNS
    443  # HTTP/3(S)
  ];
  # https://www.linode.com/docs/products/compute/compute-instances/guides/ipv6/
  networking.firewall.extraCommands = ''
    ip6tables -A INPUT -p icmpv6 -j ACCEPT
    ip6tables -A FORWARD -p icmpv6 -j ACCEPT
  '';
  networking.firewall.allowPing = true;
  networking.firewall.pingLimit = "--limit 1/minute --limit-burst 5";

  # ACME settings.
  security.acme.acceptTerms = true;
  security.acme.defaults.email = variables.webmasterEmail;
  security.acme.defaults.dnsProvider = "cloudflare";
  security.acme.defaults.credentialsFile = config.age.secrets.cloudflare-dns-api-credentials.path;

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Setting internationalisation properties to english locale and spanish keyboard.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "es";
  };

  # INSTALLED PACKAGES:
  environment.systemPackages = with pkgs; [
    # CLI tools.
    gdb
    git
    libwebp
    wget
    wp-cli

    # Miscellaneous.
    inetutils
    mtr
    sysstat
  ] ++ [ (pkgs.callPackage "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/pkgs/agenix.nix" {}) ];

  # ENABLED SERVICES:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
  services.openssh.ports = [ 2202 ];
  # https://stackoverflow.com/questions/8250379/sftp-on-linux-server-gives-error-received-message-too-long
  services.openssh.sftpServerExecutable = "internal-sftp";

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
    echo 'LINODENIX _2_'
  '';

  # Custom shell aliases.
  environment.shellAliases = {
    # Use the path to the local nixpkgs repo to rely on aditionally-tested binaries.
    # Use the bar-with-logs to display a nicer progress.
    nixos-rebuild = "nixos-rebuild -I nixpkgs=/root/workspace/nixpkgs --log-format bar-with-logs --keep-going";
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix).
  # Useful in case of accidental removal of configuration.nix.
  system.copySystemConfiguration = true;

  # Don't build documentation on this server.
  documentation.enable = false;
  documentation.man.enable = false;
  documentation.info.enable = false;
  documentation.nixos.enable = false;
  documentation.doc.enable = false;
  documentation.dev.enable = false;

  # Initial state version. Consult manual before changing.
  system.stateVersion = "22.11";

}
