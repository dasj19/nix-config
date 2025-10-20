{ lib, pkgs, ... }:

{
  imports = [
    # Hardware config.
    ./hardware.nix

    # Profile.
    ./../../profiles/laptop.nix

    # Modules.
    ./../../modules/ai.nix
    ./../../modules/non-free.nix
  ];

  # Define custom options.
  my.modules.ai.cudaSupport = false;

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  systemd.tmpfiles.rules = [
    # Silence erros:
    # jun 29 22:19:21 t14 polkitd[106479]: Loading rules from directory /run/polkit-1/rules.d
    # jun 29 22:19:21 t14 polkitd[106479]: Error opening rules directory: Error opening directory “/run/polkit-1/rules.d”: No such file or directory (g-file-error-quark, 4)
    # jun 29 22:19:21 t14 polkitd[106479]: Loading rules from directory /usr/local/share/polkit-1/rules.d
    # jun 29 22:19:21 t14 polkitd[106479]: Error opening rules directory: Error opening directory “/usr/local/share/polkit-1/rules.d”: No such file or directory (g-file-error-quark, 4)

    "d /run/polkit-1/rules.d 1777 polkituser polkituser 10d"
    "d /usr/local/share/polkit-1/rules.d 1777 polkituser polkituser 10d"
  ];

  # Configure console keymap
  console.keyMap = "es";

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Non-free software whitelist / shame list.
  allowedUnfree = [
    # Drivers.
    "nvidia-x11"
    "nvidia-settings"
    # Libraries.
    "unrar"
    # GUI.
    "drawio"
    # Server software.
    "open-webui"
  ];

  nixpkgs.config.nvidia.acceptLicense = true;

  # System-wide packages.
  environment.systemPackages = with pkgs; [
    # CLI.
    fwupd
    # GUI.
    gcstar
    # P2P.
    nicotine-plus
    sabnzbd
  ];

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  programs.usbtop.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Setup hostname.s
  networking.hostName = "t14";
  # Enable networking
  networking.networkmanager.enable = true;
  # Enable only the needed plugins.
  # Avoids # jun 29 23:04:28 t14 dbus-daemon[999]: Unknown username "nm-openconnect" in message bus configuration file
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openvpn
  ];
  # Disable mobile modem manager.
  # jun 29 22:57:07 t14 ModemManager[142228]: <msg> [base-manager] couldn't check support for device '/sys/devices/pci0000:00/0000:00:14.3': not supported by any plugin
  # jun 29 22:57:07 t14 ModemManager[142228]: <msg> [base-manager] couldn't check support for device '/sys/devices/pci0000:00/0000:00:1f.6': not supported by any plugin
  networking.modemmanager.enable = false;

  # Disable NetworkManager's internal DNS resolution.
  # https://wiki.nixos.org/wiki/NetworkManager
  networking.networkmanager.dns = "none";

  # Disable these and manage DNS ourselves.
  networking.useDHCP = false;
  networking.dhcpcd.enable = false;

  # Configure DNS servers manually.
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22 # OpenSSH
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # State version. Consult manual before changing.
  system.stateVersion = "25.11";

}
