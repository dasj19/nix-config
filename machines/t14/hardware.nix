{ config, gitSecrets, lib, modulesPath, pkgs, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 20;

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.luks.devices."luks-a2c62a27-7059-4ac5-ac4d-1408d3f86970" = {
    device = "/dev/disk/by-uuid/a2c62a27-7059-4ac5-ac4d-1408d3f86970";
    preOpenCommands = ''
      echo "###############################################################"
      echo -e "\033[31m If found, please contact Daniel:\033[0m"
      echo -e "\033[31m Email: ${gitSecrets.danielPersonalEmail}\033[0m"
      echo -e "\033[31m Phone: ${gitSecrets.danielPhoneNumber}\033[0m"
      echo -e "\033[31m Thank you!\033[0m"
      echo "###############################################################"
    '';
  };


  # Graphical LUKS password dialog. Only supported by boot.initrd.systemd
  # boot.initrd.unl0kr.enable = true;
  # Boot graphics instead of text.
  boot.plymouth.enable = true;

  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelParams = [
    # Do not display errors and commands executed during boot.
    # https://discourse.nixos.org/t/removing-persistent-boot-messages-for-a-silent-boot/14835/9
    "quiet"

    # Suppresses ACPI errors:
    # kernel: ACPI Error: Aborting method \_SB.HIDD._DSM due to previous error (AE_AML_OPERAND_TYPE) (20240827/psparse-529)
    # kernel: ACPI Error: Aborting method \ADBG due to previous error (AE_AML_OPERAND_TYPE) (20240827/psparse-529)
    # kernel: ACPI Error: AE_AML_OPERAND_TYPE, While resolving operands for [ToHexString] (20240827/dswexec-433)
    # kernel: ACPI Error: Needed [Integer/String/Buffer], found [Package] 000000006a33ef16 (20240827/exresop-469)
    "acpi_osi=!"                  # Disables OSI strings for the ACPI to pickup a generic configuration.
    ''acpi_osi="Windows 2020"''   # Tells ACPI to behave as if it was Windows 2020.


    # Disable panel self refresh function of the display.
    # Attempt at fixing:
    # i915 0000:00:02.0: [drm] *ERROR* Atomic update failure on pipe A (start=1102746 end=1102747)
    # time 840 us, min 1073, max 1079, scanline start 1029, end 1086
    "i915.enable_psr=0"
    "i915.enable_dc=0"
    "i915.atomic_support=0"
    # Disable frame buffer compression for the intel driver.
    "i915.enable_fbc=0"
    # Last resort.
    "i915.fastboot=0"
  ];
  boot.extraModulePackages = [

  ];

  boot.tmp.useTmpfs = true;
  boot.tmp.cleanOnBoot = true;
  
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/fec75069-e0f2-4aca-b708-fafe7e37db2a";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/BA2D-E52D";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver ];

  hardware.nvidia-container-toolkit.enable = true;

  # System-wide drivers and utilities.
  environment.systemPackages = with pkgs; [
    # Drivers.
    linux-firmware # needed for the intel graphic card.
    # Utilities.
    cudaPackages.cudatoolkit
  ];

  # Install fingerprinting the driver.
  # https://wiki.nixos.org/wiki/Fingerprint_scanner
  services.fprintd.enable = true;

  # Sudo login with fingerprint or password.
  # Consider trying: https://github.com/ChocolateLoverRaj/pam-any
  # security.pam.services.sudo.fprintAuth = true;
  # security.pam.services.sudo.unixAuth = true;

  # security.pam.services.sudo = lib.mkIf (config.services.fprintd.enable) {
  #   text = ''
  #     auth       sufficient   ${pkgs.fprintd}/lib/security/pam_fprintd.so
  #     auth       include      login
  #     account    include      login
  #     session    include      login
  #   '';
  # };

  # Enable TPM2 as an extra security layer. Read up first.
  # security.tpm2.enable = true;

  # Check that SSD support fstrim.
  #services.fstrim.enable = true;

  # Enable the ACPI power management daemon.
  services.acpid.enable = true;

  # Start the fprintd driver at boot
  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };

  # SMART monitoring
  services.smartd = {
    enable = true;
    notifications.mail.enable = true;
  };

  # Enable the temperature management daemon.
  services.thermald.enable = true;

  services.xserver.videoDrivers = [
    "nvidia"
  ];

  hardware.nvidia.open = false;
  hardware.nvidia.nvidiaSettings = true;
  # Check https://www.nvidia.com/en-us/drivers/results/ for the latest driver available.
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;

  hardware.nvidia.prime.offload.enable = true;
  hardware.nvidia.prime.offload.enableOffloadCmd = true;
  hardware.nvidia.prime.intelBusId = "PCI:0:2:0";   # Interface pci@0000:00:02.0
  hardware.nvidia.prime.nvidiaBusId = "PCI:45:0:0"; # Interface pci@0000:2d:00.0

  # Use syslog-ng instead of the syslog.
  services.syslog-ng.enable = true;

  # Disable fwupd service, can still be ran manually because it is installed as system package.
  services.fwupd.enable = lib.mkForce false;
}
