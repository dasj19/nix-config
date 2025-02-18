{ config, gitSecrets, pkgs, sopsSecrets, ... }:

let
  acme-webmaster = gitSecrets.gnuAcmeWebmaster;
  daniel-fullname = gitSecrets.danielFullname;
in

{
  imports = [
    # Profile.
    ./../../profiles/server.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Include email-related software configuration.
    ./email.nix
    # Include the wordpress web sites.
    ./wordpress.nix
  ]; 

  sops.defaultSopsFile = sopsSecrets;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  sops.secrets.daniel_password = {};
  sops.secrets.root_password = {};
  sops.secrets.cloudflare_email = {};
  sops.secrets.cloudflare_dns_api_token = {};
  sops.secrets.cloudflare_zone_api_token = {};

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
  security.acme.defaults.email = acme-webmaster; # Rename to acmeWebmaster.
  security.acme.defaults.dnsProvider = "cloudflare";
  security.acme.defaults.credentialFiles = {
    "CLOUDFLARE_EMAIL_FILE" = config.sops.secrets.cloudflare_email.path;
    "CF_DNS_API_TOKEN_FILE" = config.sops.secrets.cloudflare_dns_api_token.path;
    "CF_ZONE_API_TOKEN_FILE" = config.sops.secrets.cloudflare_zone_api_token.path;
  };

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Setting internationalization properties to english locale and spanish keyboard.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "es";
  # };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # INSTALLED PACKAGES:
  environment.systemPackages = with pkgs; [
    # CLI tools.
    gdb
    git
    libwebp
    w3m
    wget
    wp-cli

    # Secret management.
    sops
    git-crypt

    # Miscellaneous.
    inetutils
    mtr
    sysstat
  ];

  # ENABLED SERVICES:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
  services.openssh.ports = [ 2202 ];
  # https://stackoverflow.com/questions/8250379/sftp-on-linux-server-gives-error-received-message-too-long
  services.openssh.sftpServerExecutable = "internal-sftp";

  # Enable fish as the default shell.
  # programs.fish.enable = true;
  # users.defaultUserShell = pkgs.fish;

  # # Fish shell customizations.
  # programs.fish.interactiveShellInit = ''
  #   # Forcing true color in the terminals.
  #   set -g fish_term24bit 1
  #   # Empty fish greeting. @TODO: consider making it a nix option for fish.
  #   set -g fish_greeting ""
  #   # Add custom message to the fish prompt.
  #   echo 'LINODENIX _2_'
  # '';

  # Don't build documentation on this server.
  # documentation.enable = false;
  # documentation.man.enable = false;
  # documentation.info.enable = false;
  # documentation.nixos.enable = false;
  # documentation.doc.enable = false;
  # documentation.dev.enable = false;

  # users.mutableUsers = false;
  # users.users.daniel = {
  #   isNormalUser = true;
  #   description = daniel-fullname;
  #   hashedPasswordFile = config.sops.secrets.daniel_password.path;
  #   extraGroups = [
  #     "wheel"
  #   ];
  # };

  # users.users.root = {
  #   hashedPasswordFile = config.sops.secrets.root_password.path;
  # };

  # Initial state version. Consult manual before changing.
  system.stateVersion = "22.11";

}
