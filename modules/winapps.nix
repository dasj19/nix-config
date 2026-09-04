{
  pkgs,
  ...
}:

{
  # Enable libvirt daemon.
  virtualisation.libvirtd.enable = true;
  # Enable TPM emulation (optional)
  virtualisation.libvirtd.qemu.swtpm.enable = true;

  # Add daniel to virtualisation groups.
  users.users.daniel.extraGroups = [
    "kvm"
    "libvirtd"
  ];

  environment.systemPackages = with pkgs; [
    libayatana-appindicator # Appindicator support. Required for virt-manager.
    OVMF # UEFI firmware for QEMY and KVM.
    swtpm # Software TPM emulator.
    libtpms # Library for tpm emulation.
    tpm2-tools # Tools to access tmp.
  ];

}
