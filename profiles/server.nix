# server: a profile inherited by all servers.
# contains: common stuff that are needed on the servers.

{
  imports = [
    # Profiles.
    ./base.nix
    # Modules.
    ../modules/openssh.nix
  ];

  config = {

    networking.firewall.allowPing = true;
    networking.firewall.pingLimit = "--limit 1/minute --limit-burst 5";

    # Don't build documentation on servers.
    documentation.enable = false;
    documentation.man.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;
    documentation.doc.enable = false;
    documentation.dev.enable = false;
  };
}