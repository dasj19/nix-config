{ pkgs, ... }:

{
  imports = [
    # Evolved version from the hardware scan.
    ./hardware-configuration.nix

    # Profile.
    ./../../profiles/laptop.nix

    # Modules.
    ./../../modules/ai.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "t14";

  # Enable networking
  networking.networkmanager.enable = true;

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


  # Install firefox.
  programs.firefox.enable = true;
  # Lock preferences in place.
  programs.firefox.preferencesStatus = "locked";
  # Apply prefered policies. Inspired from https://discourse.nixos.org/t/combining-best-of-system-firefox-and-home-manager-firefox-settings/37721
  programs.firefox.policies.DisableTelemetry = true;
  programs.firefox.policies.DisableFirefoxStudies = true;
  programs.firefox.policies.DontCheckDefaultBrowser = true;
  programs.firefox.policies.DisablePocket = true;
  programs.firefox.policies.SearchBar = "unified";
  # Privacy preferences.
  programs.firefox.policies.Preferences."extensions.pocket.enabled".Value = false;
  programs.firefox.policies.Preferences."browser.newtabpage.pinned".Value = "";
  programs.firefox.policies.Preferences."browser.topsites.contile.enabled".Value = false;
  programs.firefox.policies.Preferences."browser.newtabpage.activity-stream.showSponsored".Value = false;
  programs.firefox.policies.Preferences."browser.newtabpage.activity-stream.system.showSponsored".Value = false;
  programs.firefox.policies.Preferences."browser.newtabpage.activity-stream.showSponsoredTopSites".Value = false;

  # Setup default search engine.
  programs.firefox.policies.Preferences."browser.search.defaultenginename".Value = "DuckDuckGo";
  programs.firefox.policies.Preferences."browser.search.order.1".Value = "DuckDuckGo";
  programs.firefox.policies.Preferences."browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.searchEngines".Value = "DuckDuckGo";

  # Apply extensions to all instances of Firefox system-wide.
  programs.firefox.policies.ExtensionSettings = {
    "uBlock0@raymondhill.net" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
      installation_mode = "force_installed";
    };
    "jid1-MnnxcxisBPnSXQ@jetpack" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
      installation_mode = "force_installed";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;

  # System-wide packages.
  environment.systemPackages = with pkgs; [
    # CLI.
    nvtopPackages.full
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22 # OpenSSH
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # State version. Consult manual before changing.
  system.stateVersion = "25.11";

}
