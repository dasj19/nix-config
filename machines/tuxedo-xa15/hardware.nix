{ config, lib, modulesPath, pkgs, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  config = {
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];

    # Emulate arm32 and arm64.
    boot.binfmt.emulatedSystems = [ "armv7l-linux" "aarch64-linux" ];

    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.initrd.kernelModules = [ ];
    boot.initrd.verbose = false;
    # Report just alert, critical and error.
    boot.consoleLogLevel = 3;

    boot.kernelModules = [ "kvm-amd" ];

    # Boot graphics instead of text.
    boot.plymouth.enable = true;

    # Linux kernel configuration options.
    boot.kernelParams = [
      # Do not display errors and commands executed during boot.
      # https://discourse.nixos.org/t/removing-persistent-boot-messages-for-a-silent-boot/14835/9
      "quiet"
      "rd.systemd.show_status=false" "rd.udev.log_level=3"
      "udev.log_priority=3" "boot.shell_on_fail"


      # Needed to avoid bad wakeup after suspend.
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia.NVreg_TemporaryFilePath=/tmp"

      # Attempt to fix:
      # ucsi_ccg 4-0008: ucsi_ccg_init failed - -110
      # ucsi_ccg 4-0008: i2c_transfer failed -110
      "usb_typec.disable=1"

      # Attempt to suppress ACPI kernel errors.

      # Increase ACPI logging level.
      "acpi.debug_level=0x2" "acpi.debug_layer=0xFFFFFFFF"

      # Tuxedo keyboard.
      "tuxedo_keyboard.mode=0"
      "tuxedo_keyboard.brightness=0"
    ];
    boot.extraModulePackages = [
      config.boot.kernelPackages.nvidia_x11_beta
    ];
    boot.blacklistedKernelModules = [
      # Attempt to avoid: nvidia-gpu 0000:06:00.3: i2c timeout error e0000000
      "i2c_nvidia_gpu"

      # Attempt to avoid: psmouse serio2: synaptics: Unable to query device: -5
      "psmouse"
    ];


    fileSystems."/" = {
      device = "/dev/disk/by-uuid/3db99c03-4e30-45fd-87f0-39ee08acc9c2";
      fsType = "ext4";
    };

    fileSystems."/boot" = { device = "/dev/disk/by-uuid/1442-9954";
      fsType = "vfat";
    };

    # https://nixos.wiki/wiki/NFS
    fileSystems."/mnt/md0" = {
      device = "10.0.10.182:/md0";
      fsType = "nfs";
      # fstab options.
      options = [
        "x-systemd.automount"         # Attempt mounting automatically with systemd.
        "x-systemd.idle-timeout=600"  # Disconnect after 10 minutes of inactivity.
        "noauto"                      # Can only be mounted explicitly.
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
    hardware.cpu.amd.updateMicrocode = lib.mkForce true;

    # Bluetooth.
    hardware.bluetooth.powerOnBoot = false;
  };
}
