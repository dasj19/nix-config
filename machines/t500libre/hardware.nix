{
  boot.initrd.availableKernelModules = ["uhci_hcd" "ehci_pci" "ahci" "usb_storage"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  # Disable at boot. @TODO: Recheck and update this list some day.
  boot.blacklistedKernelModules = [
    # Misc protocols.
    "firewire"
    "firewire_core"
    "firewire_ohci"
    "thinkpad_acpi"
    # Bluetooth and Wi-Fi.
    "bluetooth"
    "btusb"
    "btrtl"
    "btintel"
    "iwlwifi"
    "ath9k"
    "ath9k_common"
    "ath9k"
    # Sound modules.
    "snd"
    "snd_hda_codec"
    "snd_hda_codec_conexant"
    "snd_hda_codec_generic"
    "snd_hda_codec_hdmi"
    "snd_hda_core"
    "snd_hda_intel"
    "snd_hwdep"
    "snd_intel_nhlt"
    "snd_pcm"
    "snd_timer"
    "soundcore"
    # PCMCIA modules.
    "pcmcia"
    "pcmcia_core"
    "pcmcia_rsrc"
    # Webcam and graphics.
    "uvcvideo"
    "i915"
    "video"
    "backlight"
    # Logging.
    "watchdog"
    # Networking
    "tun"
    "tap"
    # Peripherals.
    "cdrom"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/eeea2807-66b5-4134-b964-08d40cb38a04";
    fsType = "ext4";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/6b9990be-ae4b-4358-adf0-1ce84e3c3458";}
  ];
}
