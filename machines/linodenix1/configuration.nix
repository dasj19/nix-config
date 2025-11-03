{ config, gitSecrets, lib, pkgs, ... }:

let
  baseipv6 = gitSecrets.linode1BaseIpv6;
  mailipv6 = gitSecrets.linode1MailIpv6;
in

{
  imports = [
    # Profile.
    ./../../profiles/server.nix
    # Modules.
    ./../../modules/email-server.nix
    ./../../modules/fish.nix
    ./../../modules/keyboard.nix
    ./../../modules/locale.nix
    # Include the hardware-related configuration.
    ./hardware.nix
    # Include email-related software configuration.
    ./email.nix
  ];

  # Hostname.
  networking.hostName = "linodenix1";
  networking.tempAddresses = "disabled";

  # Enables DHCP on each ethernet and wireless interface.
  networking.useDHCP = true;
  networking.enableIPv6 = true;
  # Enable DHCP on eth0.
  networking.interfaces.eth0.useDHCP = true;

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


  # Open ports in the firewall.
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    25   # SMTP
    80   # HTTP (for signing acme certificates)
    443  # HTTPS (for ssl certificates)
    465  # SMTP over TLS
    993  # IMAP secure
    2201 # SSH
  ];
  networking.firewall.allowedUDPPorts = [
    # NO UDP PORTS ALLOWED YET.
  ];
  networking.firewall.allowPing = true;
  networking.firewall.pingLimit = "--limit 1/minute --limit-burst 5";
  # Temp setting to not log refused connections.
  #networking.firewall.logRefusedConnections = false;

  # INSTALLED PACKAGES:
  environment.systemPackages = with pkgs; [
    # CLI utils.
    wget
    /* mailutils */
    git
    git-crypt
    dmidecode
    screen
  ];

  # ENABLED SERVICES:

  # OpenSSH settings.
  services.openssh.settings.PermitRootLogin  = "yes";
  services.openssh.ports = [ 2201 ];

  # Enable fail2ban with the default sshd jail, and other jails defined below.
  services.fail2ban.enable = true;

# @TODO: build a custom filter to deal with kernel access refused messages.
  services.fail2ban.jails = {
    postfix =
    ''
      filter   = postfix
      maxretry = 5
      action   = iptables[name=postfix, port=smtp, protocol=tcp]
      enabled  = true
    '';
#    kernel-access-refused = ''
#      # Block IP's that appear repeatedly in connection refused entries.
#      enable       = true
#      filter       = kernel
#      backend      = systemd
#      journalmatch = CONTAINER_TAG=kernel
#      action       = iptables-allports[actname=kernel, name=kernel, chain=INPUT]
#      findtime     = 24h
#      bantime      = 2h
#      maxretry     = 5
#    '';
  };

  # Linux kernel - Using a LTS kernel.
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_5_15;

  # Consult the manual before changing the state version.
  system.stateVersion = "21.11";

}

