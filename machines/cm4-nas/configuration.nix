{ pkgs, gitSecrets, ... }:

let

  mdmon-email = gitSecrets.danielPersonalEmail;

in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Profile.
      ./../../profiles/server.nix
    ];

  config = {
    # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
    boot.loader.grub.enable = false;
    # Enables the generation of /boot/extlinux/extlinux.conf
    boot.loader.generic-extlinux-compatible.enable = true;

    # Automount software raid at boot time.
    boot.swraid.enable = true;

    networking.hostName = "cm4-nas";
    networking.networkmanager.enable = true;

    # Server's time zone.
    time.timeZone = "Europe/Copenhagen";

    # Underpriviledged user.
    users.users.daniel = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };

    environment.systemPackages = with pkgs; [
      git
      wget
    ];

    # Open ports in the firewall.
    networking.firewall.allowedTCPPorts = [ 22 ];
    # networking.firewall.allowedUDPPorts = [ ... ];

    boot.swraid.mdadmConf = ''
      MAILADDR=${mdmon-email}
    '';

    # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    system.stateVersion = "24.11";
  };
}

