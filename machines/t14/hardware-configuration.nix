{ config, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.luks.devices."luks-a2c62a27-7059-4ac5-ac4d-1408d3f86970".device = "/dev/disk/by-uuid/a2c62a27-7059-4ac5-ac4d-1408d3f86970";

  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [
    config.boot.kernelPackages.nvidia_x11_beta
  ];

  
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

  hardware.nvidia.open = false;
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;

  hardware.nvidia.prime.offload.enable = true;
  hardware.nvidia.prime.offload.enableOffloadCmd = true;
  hardware.nvidia.prime.intelBusId = "PCI:0:2:0";   # Interface pci@0000:00:02.0
  hardware.nvidia.prime.nvidiaBusId = "PCI:45:0:0"; # Interface pci@0000:2d:00.0
}
