# t500libre: Lenovo ThinkPad T500 laptop.
# scope: machine

{
  gitSecrets,
  pkgs,
  ...
}:
let
  # Git secrets.
  acme-webmaster = gitSecrets.gnuAcmeWebmaster;

in
{
  imports = [
    # Hardware config.
    ./hardware.nix
    # Webserver configuration.
    ./caddy.nix
    # Profile.
    ./../../profiles/server.nix
  ];

  # Hostname + DHCP on all the networking interfaces.
  networking.useDHCP = true;
  networking.hostName = "t500libre";

  # List packages installed system-wide.
  environment.systemPackages = with pkgs; [
    # CLI utils.
    dnsutils
    lynx
    netcat-gnu
    openssl
    powertop
  ];

  # MySQL server.
  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;

  # SSH server settings.
  services.openssh.ports = [
    2201
  ];

  # Using Cloudflare DNS.
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];

  # Control the laptop lidswitch behavior.
  services.logind.settings.Login.HandleLidSwitch = "ignore";
  services.logind.settings.Login.HandleLidSwitchDocked = "ignore";

  # ACME properties.
  security.acme.acceptTerms = true;
  security.acme.defaults.email = acme-webmaster;
  security.acme.defaults.webroot = "/var/lib/acme/acme-challenge/";

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    # PROTOCOL - SERVER   - APP
    # WAN-open:
    # HTTP     - Apache2
    80
    # HTTPS    - Apache2
    443
    # SSH      - OpenSSH
    2201
    # LAN-open:
  ];
  networking.firewall.allowedUDPPorts = [
    # PROTOCOL - SERVER   - APP
    # WAN-open:
    # DNS      - Resolved
    53
  ];

  # Consult manual before changing.
  system.stateVersion = "26.05";
}
