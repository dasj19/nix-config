{ config, pkgs, gitSecrets, ... }:

let
  # Host-related variables.
  daniel-domain = gitSecrets.danielHackerDomain;
  daniel-email = gitSecrets.danielHackerEmail;
  daniel-fqdn = gitSecrets.danielMailserverFqdn;
in

{
  imports = [
    # Configuration.
    ./webserver.nix
    # Profile.
    ./../../profiles/server.nix
    # Modules.
    ./../../modules/email-server.nix
    ./../../modules/fish.nix
    ./../../modules/keyboard.nix
    ./../../modules/locale.nix
    ./../../modules/users.nix
    # Hardware config.
    ./hardware.nix
  ];

  # sops secrets.
  sops.secrets.root_password = {};
  sops.secrets.daniel_password = {};
  sops.secrets.daniel_daniel_email_password = {};
  sops.secrets.cloudflare_email = {};
  sops.secrets.cloudflare_dns_api_token = {};
  sops.secrets.cloudflare_zone_api_token = {};

  # Email server.
  mailserver = {
    fqdn = daniel-fqdn;
    domains = [
      daniel-domain
    ];
    loginAccounts = {
      "${daniel-email}" = {
        # For generating new hashed passwords use the following commands.
        # nix shell -p apacheHttpd
        # htpasswd -nbB "" "super secret password" | cut -d: -f2 > /hashed/password/file/location
        hashedPasswordFile = config.sops.secrets.daniel_daniel_email_password.path;
        # List of email aliases: "username@domain.tld" .
        aliases = [ "postmaster@${daniel-domain}" "webmaster@${daniel-domain}" ];
        # Catch all emails from the primary domain.
        catchAll = [ daniel-domain ];
      };
    };
  };


  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "contabo2";

  # Set server time zone.
  time.timeZone = "Europe/Copenhagen";

  # System-wide packages.
  environment.systemPackages = with pkgs; [
    # Development and Operations.
    php82Packages.composer
  ];

  # List services.

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  # @TODO: investigate if this is needed.
  services.logrotate.checkConfig = false;

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
    22  # SSH    - OpenSSH
    80  # HTTP   - Caddy Webserver.
    443 # HTTPS  - Caddy Webserver.
  ];
  networking.firewall.allowedUDPPorts = [

  ];

  # ACME settings.
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "webmaster@${daniel-domain}";
  security.acme.defaults.dnsProvider = "cloudflare";
  security.acme.defaults.credentialFiles = {
    "CLOUDFLARE_EMAIL_FILE" = config.sops.secrets.cloudflare_email.path;
    "CF_DNS_API_TOKEN_FILE" = config.sops.secrets.cloudflare_dns_api_token.path;
    "CF_ZONE_API_TOKEN_FILE" = config.sops.secrets.cloudflare_zone_api_token.path;
  };

  # Initial version. Consult manual before changing.
  system.stateVersion = "24.05";

}
