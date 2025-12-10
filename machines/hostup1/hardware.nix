{
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [
    "uhci_hcd"
    "ehci_pci"
    "ahci"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/7d33ed2c-a6d5-494d-9bd2-b80f2ff76bae";
    fsType = "ext4";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/07951f78-e2d5-4c7e-8e58-f1b12f570557"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  # Guest additions for Qemu.
  services.spice-vdagentd.enable = true;

}
