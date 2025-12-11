{
  config,
  gitSecrets,
  lib,
  pkgs,
  sopsSecrets,
  ...
}:

let
  acme-webmaster = gitSecrets.gnuAcmeWebmaster;
  baseipv6 = gitSecrets.linode2BaseIpv6;
  mailipv6 = gitSecrets.linode2MailIpv6;
  home-ip = gitSecrets.homeIp;
in

{
  imports = [
    # Profile.
    ./../../profiles/server.nix
    # Hardware config.
    ./hardware.nix
    # Email config.
    ./email.nix
    # Wordpress sites config.
    ./wordpress.nix
  ];

  sops.defaultSopsFile = sopsSecrets;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  sops.secrets.daniel_password = { };
  sops.secrets.root_password = { };
  sops.secrets.cloudflare_email = { };
  sops.secrets.cloudflare_dns_api_token = { };
  sops.secrets.cloudflare_zone_api_token = { };

  # Host and network settings.
  networking.enableIPv6 = true;
  networking.interfaces.eth0.ipv6.addresses = [
    {
      address = "${baseipv6}";
      prefixLength = 128;
    }
    {
      address = "${mailipv6}";
      prefixLength = 128;
    }
  ];
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "eth0";
  };
  networking.hostName = "linodenix2";
  networking.networkmanager.enable = false;
  networking.usePredictableInterfaceNames = false;
  networking.tempAddresses = "disabled";
  networking.useDHCP = true;

  # Open ports in the firewall.
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    25 # SMTP
    22 # SSH - OpenSSH
    53 # DNS
    80 # HTTP
    143 # IMAP
    443 # HTTPS
    465 # SMTP over TLS
    993 # IMAP over TLS
  ];
  networking.firewall.allowedUDPPorts = [
    53 # DNS
    443 # HTTP/3(S)
  ];
  # https://www.linode.com/docs/products/compute/compute-instances/guides/ipv6/
  networking.firewall.extraCommands = ''
    ip6tables -A INPUT -p icmpv6 -j ACCEPT
    ip6tables -A FORWARD -p icmpv6 -j ACCEPT
  '';

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

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.fail2ban.enable = true;
  services.fail2ban.bantime = "24h";
  services.fail2ban.ignoreIP = [ home-ip ];
  # Apply bans on all ports, based on firewall output.
  services.fail2ban.extraPackages = [ pkgs.ipset ];
  services.fail2ban.banaction = "iptables-ipset-proto6-allports";

  # INSTALLED PACKAGES:
  environment.systemPackages = with pkgs; [
    # CLI tools.
    gdb
    libwebp
    wp-cli

    # Miscellaneous.
    mtr
    sysstat
  ];

  # ENABLED SERVICES:

  # OpenSSH settings.
  services.openssh.ports = [
    22
  ];

  # Linux kernel - Using a LTS kernel.
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_5_15;

  # Initial state version. Consult manual before changing.
  system.stateVersion = "22.11";

}
