{ pkgs, ... }:

{
  imports = [
    # Hardware config.
    ./hardware.nix

    # Profile.
    ./../../profiles/laptop.nix

    # Modules.
    ./../../modules/ai.nix
  ];

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure console keymap
  console.keyMap = "es";

  # Enable CUPS to print documents.
  services.printing.enable = true;

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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;

  # System-wide packages.
  environment.systemPackages = with pkgs; [
    # CLI.
    nvtopPackages.full
    # P2P.
    nicotine-plus
  ];

  programs.usbtop.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Setup hostname.s
  networking.hostName = "t14";
  # Enable networking
  networking.networkmanager.enable = true;
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22 # OpenSSH
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # State version. Consult manual before changing.
  system.stateVersion = "25.11";

}
