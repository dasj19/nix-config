{ config, lib, pkgs, ... }:


let
  gitSecrets = builtins.fromJSON(builtins.readFile ./secrets/git-secrets.json);
  gnu-domain = gitSecrets.gnuDomain;
  acme-webmaster = gitSecrets.acmeWebmaster;
  searxng-secret = gitSecrets.searxngSecret;

  # Agenix paths:
  localhost-account-daniel-password = config.age.secrets.localhost-account-daniel-password.path;
  localhost-account-root-password = config.age.secrets.localhost-account-root-password.path;
  sshserver-authorized-keys = config.age.secrets.sshserver-authorized-keys.path;

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
      # Email server configuration.
      ./email.nix
      # Agenix secret management.
      "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/modules/age.nix"
    ];

  # Agenix secrets.
  age.secrets.localhost-account-root-password.file = secrets/localhost-account-root-password.age;
  age.secrets.localhost-account-daniel-password.file = secrets/localhost-account-daniel-password.age;
  age.secrets.sshserver-authorized-keys.file = secrets/sshserver-authorized-keys.age;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  # Linux kernel - Using a LTS kernel. 6.6 is good until December 2026.
  # Check if kernel was updated: ls -l /run/{booted,current}-system/kernel*
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;

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

  # Hostname + DHCP on all the networking interfaces.
  networking.useDHCP = true;
  networking.hostName = "t500libre";

  # Select internationalization properties. @TODO: Recheck and revise these settings.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "da_DK.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
  ];
  # Font and keymap for the console.
  console = {
    font = "Lat2-Terminus16";
    keyMap = "es";
  };

  # System's Timezone.
  time.timeZone = "Europe/Copenhagen";

  # List packages installed system-wide.
  environment.systemPackages = with pkgs; [
    # CLI utils.
    wget vim w3m git netcat-gnu tree lynx
    powertop dnsutils openssl lsof nmap
    rathole

    # Encryption.
    git-crypt
    sops

    # Secrets management, agenix.
    (pkgs.callPackage "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/pkgs/agenix.nix" {})

    # Server applications.
    apacheHttpd_2_4 apacheHttpdPackages.mod_cspnonce libmodsecurity
    php82
    searxng
  ];

  # Enable the avahi mDNS service.
  services.avahi.enable = true;
  services.avahi.hostName = "t500libre";

  # MySQL server.
  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.authorizedKeysFiles = [ sshserver-authorized-keys ];

  services.openssh.hostKeys = [
    {
      bits = 4096;
      openSSHFormat = true;
      path = "/etc/ssh/ssh_host_rsa_key";
      rounds = 100; type = "rsa";
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
          keep_only = [ "google" "duckduckgo" ];
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

  # Control the laptop lidswitch behaviour.
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchDocked = "ignore";

  # ACME properties.
  security.acme.acceptTerms = true;
  security.acme.defaults.email = acme-webmaster;
  security.acme.defaults.webroot = "/var/lib/acme/acme-challenge/";
  # Use variables for domain names.
  security.acme.certs = {
    "archive.gnu.style" = {
      webroot = "/var/lib/acme/acme-challenge/";
    };
    "searx.gnu.style" = {
      webroot = "/var/lib/acme/acme-challenge/";
    };
    "mail.gnu.style" = {
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

  # Enable basic fail2ban (Only has sshd jail).
  services.fail2ban.enable = true;
  services.fail2ban.jails = {
    # Block dovecot failed login attepmts and aborted connections.
    dovecot = ''
      enabled = true
      filter = dovecot[mode=aggressive]
      maxretry = 3
    '';
  };

  # Allow immutable users.
  users.mutableUsers = false;

  # The root user.
  users.users.root = {
    hashedPasswordFile = localhost-account-root-password;
  };

  # Local unpriviledged user accunt.
  users.users.daniel = {
    isNormalUser = true;
    hashedPasswordFile = localhost-account-daniel-password;
    extraGroups = [ "wheel" "wwwrun" ];
  };

  # Standard motd for all users of this host.
  users.motdFile = "/etc/nixos/motd.txt";

  # Make the fish shell default for the entire system.
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Fish shell customizations.
  # @TODO: consider transforming these into nix options for fish.
  programs.fish.interactiveShellInit = ''
    # Enable true color for the terminal.
    set -g fish_term24bit 1
    # Empty fish greeting.
    set -g fish_greeting ""
  '';

  # Custom shell aliases.
  environment.shellAliases = {
    # Includes the path to the nixpkgs fork to pickup our own updates.
    nixos-rebuild = "nixos-rebuild -I nixpkgs=/root/workspace/nixpkgs --log-format bar-with-logs --keep-going";
  };

  # Initial version. Consult manual before changing.
  system.stateVersion = "21.11";
}
