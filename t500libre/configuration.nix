{ config, lib, pkgs, ... }:


let 

  # A custom python used mainly for searx dependencies.
  my-python-packages = python-packages: with python-packages; [
    Babel httpcore httpx httpx-socks uvloop requests
    langdetect lxml pyaml pygments python-dateutil werkzeug flask flask-babel h2
  ]; 
  python-with-my-packages = pkgs.python311.withPackages my-python-packages;

  # Agenix strings:
  acme-account-webmaster-email = lib.strings.fileContents config.age.secrets.acme-account-webmaster-email.path;
  gnu-domain = lib.strings.fileContents config.age.secrets.webserver-virtualhost-gnu-domain.path;
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
  age.secrets.acme-account-webmaster-email.file = secrets/acme-account-webmaster-email.age;
  age.secrets.localhost-account-root-password.file = secrets/localhost-account-root-password.age;
  age.secrets.localhost-account-daniel-password.file = secrets/localhost-account-daniel-password.age;
  age.secrets.sshserver-authorized-keys.file = secrets/sshserver-authorized-keys.age;
  age.secrets.webserver-virtualhost-gnu-domain.file = secrets/webserver-virtualhost-gnu-domain.age;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # Linux kernel - Using a LTS kernel.
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_5_15;

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

  # Hostname + no DHCP on the machines networking interfaces.
  networking.useDHCP = false;
  networking.hostName = "t500libre";
  networking.interfaces.enp0s25.useDHCP = true;

  # Select internationalization properties. @TODO: Recheck and revise these settings.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "da_DK.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
  ];
  # Font an keymap for the console.
  console = {
    font = "Lat2-Terminus16";
    keyMap = "es";
  };

  # System's Timezone.
  time.timeZone = "Europe/Copenhagen";

  # List packages installed system-wide.
  environment.systemPackages = with pkgs; [
    # Libraries

    # CLI utils.
    wget vim w3m git netcat-gnu tree lynx
    powertop dnsutils openssl lsof
    # Secrets management, agenix.
    (pkgs.callPackage "${builtins.fetchTarball "https://github.com/ryantm/agenix/archive/main.tar.gz"}/pkgs/agenix.nix" {})

    # Server applications.
    apacheHttpd_2_4 php80 apacheHttpdPackages.mod_cspnonce
    libmodsecurity
    filtron

    # Required for local searx instance:
    python-with-my-packages searx uwsgi shellcheck
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

  # SSH server settings.
  services.openssh.extraConfig = "MaxAuthTries 20";
  services.openssh.ports = [ 2201 ];
  services.openssh.settings.PermitRootLogin = "without-password";

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

  # Control the lidswitch behaviour.
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchDocked = "ignore";

  # Startup a main searx server. Not a nixos stock because of better customizability.
  systemd.services.searx = {
      wantedBy      = [ "multi-user.target" ]; 
      after         = [ "network.target" ];
      description   = "Start a searx instance.";
      serviceConfig = {
        User = "searx";
        ExecStart = ''
           ${python-with-my-packages}/bin/python3 /var/www/searx.${gnu-domain}/searx/webapp.py
        '';
        Environment = [
          "SEARX_SETTINGS_PATH=/var/www/searx.${gnu-domain}/searx-config-1.0.yml"
        ];         
      };
   };
 
  # Startup a filtron server.
  systemd.services.filtron = {
      wantedBy = [ "multi-user.target" ]; 
      after = [ "network.target" ];
      description = "Start a filtron instance.";
      serviceConfig = {
        User = "filtron";
        ExecStart = ''
          ${pkgs.filtron}/bin/filtron -api "127.0.0.1:4005" -rules /var/www/filtron/filtron-rules.json -target "127.0.0.1:8100"
        '';
      };
   };

  # ACME properties.
  security.acme.acceptTerms = true;
  security.acme.defaults.email = acme-account-webmaster-email;
  
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
    # 4822 #          - Guacamole
      8001 # HTTP     - Nginx    - Kanboard
    # Host-restricted:
    # 8100 # HTTP     - Werkzeug - Searx
    # 4005 # HTTP     - Fasthttp - Filtron
  ];
  networking.firewall.allowedUDPPorts = [
    # PORT - PROTOCOL - SERVER   - APP
    # WAN-open:
      53   # DNS      - Resolved 
  ];

  # Allow immutable users.
  users.mutableUsers = false;

  # The root user.
  users.users.root = {
    passwordFile = localhost-account-root-password;
  };

  # Local unpriviledged user accunt.
  users.users.daniel = {
    isNormalUser = true;
    passwordFile = localhost-account-daniel-password;
    extraGroups = [ "wheel" "wwwrun" ];
  };

  # Standard motd for all users of this host.
  #users.motd = lib.strings.fileContents "${./motd.txt}";

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
    nixos-rebuild = "nixos-rebuild -I nixpkgs=/root/workspace/nixpkgs --keep-going";
  };

  # System users and their groups.
  users.users.filtron.group = "filtron";
  users.users.filtron.isSystemUser = true;
  users.groups.filtron = {};

  users.users.searx.group = "searx";
  users.users.searx.isSystemUser = true;
  users.groups.searx = {};

  # Initial version. Consult manual before changing.
  system.stateVersion = "20.09";
}
