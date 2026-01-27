/*
  * t14: my daily driver laptop
  * model: Lenovo T14 Gen1
  *
  * Notes:
  *  - any offline AI work has to be done on CPU which is very slow,
  *    therefore online AI should be used instead.
  *  - sudo-rs is set up to be used using fingerprint first but has password prompt as fallback.
*/
{ lib, pkgs, ... }:
{
  imports = [
    # Hardware config.
    ./hardware.nix

    # Development environment.
    ./development.nix

    # Profile.
    ./../../profiles/laptop.nix

    # Modules.
    ./../../modules/ai.nix
    ./../../modules/non-free.nix
  ];

  # Define custom options.
  my.modules.ai.cudaSupport = false;

  systemd.tmpfiles.rules = [
    # Silence erros:
    # jun 29 22:19:21 t14 polkitd[106479]: Loading rules from directory /run/polkit-1/rules.d
    # jun 29 22:19:21 t14 polkitd[106479]: Error opening rules directory: Error opening directory “/run/polkit-1/rules.d”: No such file or directory (g-file-error-quark, 4)
    # jun 29 22:19:21 t14 polkitd[106479]: Loading rules from directory /usr/local/share/polkit-1/rules.d
    # jun 29 22:19:21 t14 polkitd[106479]: Error opening rules directory: Error opening directory “/usr/local/share/polkit-1/rules.d”: No such file or directory (g-file-error-quark, 4)

    "d /run/polkit-1/rules.d 1777 polkituser polkituser 10d"
    "d /usr/local/share/polkit-1/rules.d 1777 polkituser polkituser 10d"
  ];

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Non-free software whitelist / shame list.
  allowedUnfree = [
    # GUI.
    "discord"
    # Server software.
    "open-webui"
  ];

  # t14 has a total of 8 cores.
  # Builds max 4 parallel jobs at once using at most 2 cores per job.
  # @see https://nix.dev/manual/nix/2.22/advanced-topics/cores-vs-jobs
  nix.settings.max-jobs = lib.mkForce 4;
  nix.settings.cores = lib.mkForce 2;

  # System-wide packages.
  environment.systemPackages = with pkgs; [
    # CLI.
    fwupd
    lrcget

    # GUI.
    gcstar
    discord
    mailspring

    # P2P.
    nicotine-plus
    sabnzbd
  ];

  # Enable virtualization.
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  # Measures USB traffic bandwidth.
  programs.usbtop.enable = true;

  # Setup hostname.s
  networking.hostName = "t14";

  # State version. Consult manual before changing.
  system.stateVersion = "25.11";
}
