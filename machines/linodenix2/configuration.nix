{ config, gitSecrets, lib, pkgs, sopsSecrets, ... }:

let
  acme-webmaster = gitSecrets.gnuAcmeWebmaster;
  baseipv6 = gitSecrets.linode2BaseIpv6;
  mailipv6 = gitSecrets.linode2MailIpv6;
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

  sops.secrets.daniel_password = {};
  sops.secrets.root_password = {};
  sops.secrets.cloudflare_email = {};
  sops.secrets.cloudflare_dns_api_token = {};
  sops.secrets.cloudflare_zone_api_token = {};

  # Host and network settings.
  networking.enableIPv6  = true;
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
    25   # SMTP
    53   # DNS
    80   # HTTP
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

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # INSTALLED PACKAGES:
  environment.systemPackages = with pkgs; [
    # CLI tools.
    gdb
    libwebp
    w3m
    wp-cli

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

  # Linux kernel - Using a LTS kernel.
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_5_15;

  # Initial state version. Consult manual before changing.
  system.stateVersion = "22.11";

}
