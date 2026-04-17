{
  config,
  gitSecrets,
  pkgs,
  ...
}:
let
  # Git secrets.
  gnu-domain = gitSecrets.gnuDomain;
  acme-webmaster = gitSecrets.gnuAcmeWebmaster;
  mailserver-fqdn = gitSecrets.gnuMailserverFqdn;
  mailserver-daniel-email = gitSecrets.gnuMailserverDanielEmail;

  # This is one of the last immich versions that depends on
  # immich-machine-learning which uses numpy < 2.4
  immich-pinned = import (builtins.fetchTarball {
    url = "https://github.com/nixos/nixpkgs/tarball/96d2c59f3aab1797226505240a77f767023c6a22";
    sha256 = "10x1mpi2ga3rwvm6kr4l2l060cxjlg6vmwk27v7byrxxflc7ir6j";
  }) {
    inherit (config.nixpkgs) config;
    system = "x86_64-linux";
  };

in
{
  imports = [
    # Hardware config.
    ./hardware.nix
    # Webserver configuration.
    ./httpd.nix
    # Profile.
    ./../../profiles/server.nix
    # Modules.
    ./../../modules/builder.nix
    ./../../modules/email-server.nix
  ];

  # sops secrets.
  sops.secrets.root_password = { };
  sops.secrets.daniel_password = { };
  sops.secrets.daniel_gnu_email_password = { };

  # Defining variables for the email-server module.
  mailserver = {
    fqdn = mailserver-fqdn;
    x509.useACMEHost = mailserver-fqdn;
    domains = [
      gnu-domain
    ];
    accounts = {
      # Account name in the form of "username@domain.tld".
      "${mailserver-daniel-email}" = {
        # Password can be generated running: 'mkpasswd -sm bcrypt'.
        hashedPasswordFile = config.sops.secrets.daniel_gnu_email_password.path;
        # List of aliases in format: [ "username@domain.tld" ].
        aliases = [
          "postmaster@${gnu-domain}"
          "tor@${gnu-domain}"
          "webmaster@${gnu-domain}"
        ];
      };
    };
  };

  nixpkgs.config = {

    packageOverrides = pkgs: {
      # Overriding the rspamd package replacing vectorscan with hyperscan.
      rspamd = pkgs.rspamd.overrideAttrs (oldAttrs: {
        # Replacing vectorscan with hyperscan.
        # Vectorscan is not compatible with the old CPU of t500libre.
        buildInputs = builtins.filter (pkg: pkg != pkgs.vectorscan) oldAttrs.buildInputs ++ [
          pkgs.hyperscan
        ];
      });
    };
  };

  # Hostname + DHCP on all the networking interfaces.
  networking.useDHCP = true;
  networking.hostName = "t500libre";

  # List packages installed system-wide.
  environment.systemPackages = with pkgs; [
    # CLI utils.
    netcat-gnu
    lynx
    powertop
    dnsutils
    openssl

    # Server applications.
    apacheHttpd_2_4
    apacheHttpdPackages.mod_cspnonce
    libmodsecurity
    php82
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

  # Immich server.
  services.immich.enable = true;
  services.immich.package = immich-pinned.immich;
  services.immich.port = 2283;
  services.immich.host = "0.0.0.0";
  services.immich.openFirewall = true;
  services.immich.machine-learning.enable = true;


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
    # SMTPS    - Postfix
    465
    # IMAPS    - Dovecot
    993
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

  # Allow immutable users.
  # Consider adopting userborn: https://github.com/NixOS/nixpkgs/pull/332719
  # users.mutableUsers = false;

  # Consult manual before changing.
  system.stateVersion = "26.05";
}
