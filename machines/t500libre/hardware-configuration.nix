{ ... }:

{
  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "usb_storage" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/eeea2807-66b5-4134-b964-08d40cb38a04";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/6b9990be-ae4b-4358-adf0-1ce84e3c3458"; }
    ];
}
