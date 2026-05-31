# cm4-nas: hardware configuration for a CM4 on a Raxda Taco v1.3
# @todo: investigate how we can have the taco working on a newer kernel.


{
  lib,
  modulesPath,
  pkgs,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  # Don't go above 6.1 because of pcie controller hardware compatibility.
  boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_6_1;
  boot.kernelModules = [
    # No kernel modules yet.
  ];
  boot.kernelParams = [
    # Drop a shell when the kernel fails.
    "boot.shell_on_fail"
  ];
  boot.extraModulePackages = [ ];

  # Not working yet:
  # Hardware overlay to allow using the penta-hat with a newer kernel.
  # hardware.deviceTree.enable = true;
  # hardware.deviceTree.filter = "*rpi*.dtb";
  # hardware.deviceTree.overlays = [
  #  {
  #    name = "pcie-32bit-dma";
  #    dtboFile = "${pkgs.device-tree_rpi.overlays}/pcie-32bit-dma.dtbo";
  #  }
  #];


  # Mount the root filesystem.
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
      fsType = "ext4";
    };

  # Mount the raid disks onto /mnt/md0.
  fileSystems."/mnt/md0" =
    { device = "/dev/disk/by-uuid/5f480d33-ec91-4797-82cf-36118b7576fc";
      fsType = "ext4";
    };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

}

