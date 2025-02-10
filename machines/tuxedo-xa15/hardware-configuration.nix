{ config, lib, modulesPath, pkgs, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];


  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3db99c03-4e30-45fd-87f0-39ee08acc9c2";
    fsType = "ext4";
  };

  fileSystems."/boot" = { device = "/dev/disk/by-uuid/1442-9954";
    fsType = "vfat";
  };

  fileSystems."/mnt/md0" = {
    device = "10.0.10.182:/md0";
    fsType = "nfs";
    # fstab options.
    options = [
      # Attempt mounting automatically with systemd.
      "x-systemd.automount"
      # Can only be mounted explicitly.
      #"noauto"
    ];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/05abcb75-5a7c-46b2-9f8c-e8fadf93b7a3";
    }
  ];

  # Enable scanning support.
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];

  # AMD.
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Tuxedo drivers support.
  hardware.tuxedo-drivers.enable = true;
  # Control programs.
  hardware.tuxedo-rs.enable = false;
  hardware.tuxedo-rs.tailor-gui.enable = false;

  # Enable OpenGL
  hardware.graphics.enable = true;

  # Use the NVidia open source kernel module (not to be confused with the
  # independent third-party "nouveau" open source driver).
  # Support is limited to the Turing and later architectures. Full list of
  # supported GPUs is at:
  # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
  # Only available from driver 515.43.04+
  # Currently alpha-quality/buggy, so false is currently the recommended setting.
  hardware.nvidia.open = true;

  # Enable the Nvidia settings menu,
  # accessible via `nvidia-settings`.
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  # Needed for properly suspend.
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.modesetting.enable = true;

  # System Management Unit kernel driver.
  hardware.cpu.amd.ryzen-smu.enable = true;

}
