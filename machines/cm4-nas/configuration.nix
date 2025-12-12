{ pkgs, gitSecrets, ... }:

let

  mdmon-email = gitSecrets.danielPersonalEmail;

in

{
  imports = [
    # Hardware config.
    ./hardware.nix
    # Profile.
    ./../../profiles/server.nix
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # Automount software raid at boot time.
  boot.swraid.enable = true;

  networking.hostName = "cm4-nas";
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    iperf
  ];

  fileSystems."/export/md0" = {
    device = "/mnt/md0";
    options = [ "bind" ];
  };

  # Enable NFS.
  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /export		10.0.10.0/24(insecure,rw,sync,no_subtree_check,crossmnt,fsid=0)
    /export/md0		10.0.10.0/24(insecure,rw,sync,no_subtree_check)
  '';
  services.nfs.server.lockdPort = 4001;
  services.nfs.server.mountdPort = 4002;
  services.nfs.server.statdPort = 4000;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22 # SSH
    111 # NFS
    2049 # NFS
    4000 # NFS
    4001 # NFS
    4002 # NFS
    5201 # iperf
    20048 # NFS
  ];
  networking.firewall.allowedUDPPorts = [
    111 # NFS
    2049 # NFS
    4000 # NFS
    4001 # NFS
    20048 # NFS
    4002 # NFS
    5201 # iperf
  ];

  boot.swraid.mdadmConf = ''
    MAILADDR=${mdmon-email}
  '';

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11";

}
