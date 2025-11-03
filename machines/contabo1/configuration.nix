/*
 * contabo1: github runner, mailserver, webserver
 * model: Contabo SSD VPS
 *
 * Notes:
 *  - can be busy at times, especially
 *    after I push new updates to the config
 */

{ config, gitSecrets, pkgs, sopsSecrets, ... }:

let
  fritweb-domain = gitSecrets.fritwebDomain;
  baseipv6 = gitSecrets.contabo1BaseIpv6;
in

{
  imports = [ 
    # Profile.
    ./../../profiles/server.nix
    # Include the results of the hardware scan.
    ./hardware.nix
    # Email server configuration.
    ./email.nix
    # Webserver applications.
    ./webserver.nix
  ];

  # Sops configuration.
  sops.defaultSopsFile = sopsSecrets;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # Sops secrets.
  sops.secrets.daniel_password = {};
  sops.secrets.root_password = {};
  sops.secrets.cloudflare_email = {};
  sops.secrets.cloudflare_dns_api_token = {};
  sops.secrets.cloudflare_zone_api_token = {};

  networking.hostName = "contabo1";
  networking.enableIPv6  = true;

  networking.interfaces.ens18.ipv6.addresses = [
    # Static IPv6 address for the main interface.
    {
      address = "${baseipv6}";
      prefixLength = 64;
    }
  ];
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "ens18";
  };

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # contabo1 has 4 cores
  # Build one job at a time using maximum of 4 cores per jobs. (no parallel builds)
  nix.settings.max-jobs = 1;
  nix.settings.cores = 4;

  nix.settings.trusted-users = [
    "daniel"
  ];


  # Github runner to build the nix-config repo/project.
  services.github-runners."nix-config-runner" = {
    enable = true;
    name = "nix-config-runner";
    tokenFile = "/etc/nixos/nix-config-runner.token";
    url = "https://github.com/dasj19/nix-config";
    extraPackages = [ pkgs.git-crypt ];
  };

  # Packages installed in system profile.
  environment.systemPackages = with pkgs; [
    # CLI utils.
    postgresql
  ];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22   # OpenSSH.
    25   # SMTP.
    80   # HTTP.
    143  # IMAP.
    443  # HTTPS.
    465  # SMTP over TLS.
    993  # IMAP over TLS.
    5600 # Airdc++ insecure
    5601 # Airdc++ secure
    39425 # Airdc transfer
    41645 # Airdc encrypted transfer
  ];
  networking.firewall.allowedUDPPorts = [
    43553 # Airdc search port
  ];

  # https://www.linode.com/docs/products/compute/compute-instances/guides/ipv6/
  networking.firewall.extraCommands = ''
    ip6tables -A INPUT -p icmpv6 -j ACCEPT
    ip6tables -A FORWARD -p icmpv6 -j ACCEPT
  '';
  networking.firewall.allowPing = true;
  networking.firewall.pingLimit = "--limit 1/minute --limit-burst 5";

  services.logrotate.checkConfig = false;

  # ACME settings.
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "webmaster@${fritweb-domain}";
  security.acme.defaults.dnsProvider = "cloudflare";
  # security.acme.defaults.credentialsFile = config.age.secrets.cloudflare-dns-api-credentials.path;
  security.acme.defaults.credentialFiles = {
    "CLOUDFLARE_EMAIL_FILE" = config.sops.secrets.cloudflare_email.path;
    "CF_DNS_API_TOKEN_FILE" = config.sops.secrets.cloudflare_dns_api_token.path;
    "CF_ZONE_API_TOKEN_FILE" = config.sops.secrets.cloudflare_zone_api_token.path;
  };

  # Initial version. Check manual before changing.
  system.stateVersion = "24.05";

}

