{
  config,
  gitSecrets,
  pkgs,
  ...
}: let
  # Git secrets.
  gnu-domain = gitSecrets.gnuDomain;
  acme-webmaster = gitSecrets.gnuAcmeWebmaster;
  searxng-secret = gitSecrets.gnuSearxngSecret;
  mailserver-fqdn = gitSecrets.gnuMailserverFqdn;
  mailserver-daniel-email = gitSecrets.gnuMailserverDanielEmail;
in {
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
  sops.secrets.root_password = {};
  sops.secrets.daniel_password = {};
  sops.secrets.daniel_gnu_email_password = {};

  # Defining variables for the email-server module.
  mailserver = {
    fqdn = mailserver-fqdn;
    domains = [
      gnu-domain
    ];
    loginAccounts = {
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
        buildInputs =
          builtins.filter (pkg: pkg != pkgs.vectorscan) oldAttrs.buildInputs
          ++ [pkgs.hyperscan];
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
    searxng
  ];

  # MySQL server.
  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;

  # A searxng instance.
  services.searx = {
    enable = true;
    settings = {
      use_default_settings = {
        engines = {
          # for some reason remove directive does not work on "qwant".
          keep_only = [
            "google"
            "duckduckgo"
          ];
        };
      };
      server = {
        port = 8100;
        bind_address = "127.0.0.1";
        secret_key = searxng-secret;
      };
    };
  };

  # SSH server settings.
  services.openssh.ports = [
    2201
  ];

  # Local DNS cache server. @TODO: Check to what extent is this used.
  services.resolved.enable = true;
  services.resolved.dnssec = "allow-downgrade";
  services.resolved.extraConfig = ''
    DNSOverTLS=opportunistic
  '';

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
  # Use variables for domain names.
  security.acme.certs = {
    "archive.${gnu-domain}" = {
      webroot = "/var/lib/acme/acme-challenge/";
    };
    "searx.${gnu-domain}" = {
      webroot = "/var/lib/acme/acme-challenge/";
    };
    "mail.${gnu-domain}" = {
      webroot = "/var/lib/acme/acme-challenge/";
    };
  };

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
    # HTTP     - Nginx    - Nextcloud
    8001
    # Host-restricted:
    # 8100 # HTTP     - Werkzeug - SearxNG
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

  # The root user.
  users.users.root = {
    hashedPasswordFile = config.sops.secrets.root_password.path;
  };

  # Local unprivileged user account.
  users.users.daniel = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.daniel_password.path;
    extraGroups = [
      "wheel"
      "wwwrun"
    ];
  };

  # Consult manual before changing.
  system.stateVersion = "24.11";
}
