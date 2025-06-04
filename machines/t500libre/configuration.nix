{ config, pkgs, gitSecrets, ... }:


let

  # Git secrets.
  gnu-domain = gitSecrets.gnuDomain;
  acme-webmaster = gitSecrets.gnuAcmeWebmaster;
  searxng-secret = gitSecrets.gnuSearxngSecret;
  mailserver-fqdn = gitSecrets.gnuMailserverFqdn;
  mailserver-daniel-email = gitSecrets.gnuMailserverDanielEmail;

in

{
  imports =
    [ 
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Webserver configuration.
      ./httpd.nix
      # Kanboard configuration.
      ./kanboard.nix
      # Modules.
      ./../../modules/fish.nix
      ./../../modules/keyboard.nix
      ./../../modules/locale.nix
      ./../../modules/users.nix
      ./../../modules/email-server.nix
      # Profile.
      ./../../profiles/server.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  # Disable at boot. @TODO: Recheck and update this list some day.
  boot.blacklistedKernelModules = [
    # Misc protocols.
    "firewire" "firewire_core" "firewire_ohci" "thinkpad_acpi"
    # Bluetooth and Wi-Fi.
    "bluetooth" "btusb" "btrtl" "btintel"
    "iwlwifi" "ath9k" "ath9k_common" "ath9k"
    # Sound modules.
    "snd" "snd_hda_codec" "snd_hda_codec_conexant"
    "snd_hda_codec_generic" "snd_hda_codec_hdmi"
    "snd_hda_core" "snd_hda_intel" "snd_hwdep"
    "snd_intel_nhlt" "snd_pcm" "snd_timer"
    "soundcore"
    # PCMCIA modules.
    "pcmcia" "pcmcia_core" "pcmcia_rsrc"
    # Webcam and graphics.
    "uvcvideo" "i915" "video" "backlight"
    # Logging.
    "watchdog"
    # Networking
    "tun" "tap"
    # Peripherals.
    "cdrom" 
  ];

  # sops secrets.
  sops.secrets.root_password = {};
  sops.secrets.daniel_password = {};
  sops.secrets.daniel_gnu_email_password = {};

  # Hostname + DHCP on all the networking interfaces.
  networking.useDHCP = true;
  networking.hostName = "t500libre";

  # Email server settings.
  mailserver.fqdn = mailserver-fqdn;
    # list of domains in format: [ "domain.tld" ];
  mailserver.domains = [ gnu-domain ];
  mailserver.loginAccounts = {
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
  mailserver.stateVersion = 1;

  # List packages installed system-wide.
  environment.systemPackages = with pkgs; [
    # CLI utils.
    w3m
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

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.openssh.hostKeys = [
    {
      bits = 4096;
      openSSHFormat = true;
      path = "/etc/ssh/ssh_host_rsa_key";
      rounds = 100;
      type = "rsa";
    }
    {
      comment = "t500libre";
      path = "/etc/ssh/ssh_host_ed25519_key";
      rounds = 100;
      type = "ed25519";
    }
  ];

  # A searxng instance.
  services.searx = {
    enable = true;
    settings = {
      use_default_settings = {
        engines = {
          # for some reason remove directive does not work on "qwant".
          keep_only = [ "google" /* "duckduckgo" */ ];
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
  services.openssh.extraConfig = "MaxAuthTries 20";
  services.openssh.ports = [ 2201 ];
  services.openssh.settings.PermitRootLogin = "yes";

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
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchDocked = "ignore";

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
    # PORT - PROTOCOL - SERVER   - APP
    # WAN-open:
      25   # SMTP     - Postfix
      80   # HTTP     - Apache2
      443  # HTTPS    - Apache2
      465  # SMTPS    - Postfix
      993  # IMAPS    - Dovecot
      2201 # SSH      - OpenSSH
    # LAN-open:
      8001 # HTTP     - Nginx    - Kanboard
    # Host-restricted:
    # 8100 # HTTP     - Werkzeug - SearxNG
  ];
  networking.firewall.allowedUDPPorts = [
    # PORT - PROTOCOL - SERVER   - APP
    # WAN-open:
      53   # DNS      - Resolved 
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
    extraGroups = [ "wheel" "wwwrun" ];
  };

  # Standard motd for all users of this host.
  users.motdFile = "/etc/nixos/motd.txt";

  # Consult manual before changing.
  system.stateVersion = "24.11";
}
