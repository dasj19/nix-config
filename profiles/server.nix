# server: a profile inherited by all servers.
# scope: servers
# contains: common stuff that are needed on the servers.
{
  pkgs,
  ...
}:
{
  imports = [
    # Profiles.
    ./base.nix
    # Modules.
    ../modules/openssh.nix
  ];

  networking.firewall.allowPing = true;
  networking.firewall.pingLimit = "--limit 1/minute --limit-burst 5";

  environment.systemPackages = with pkgs; [
    goaccess # log analyzer
  ];

  # A 128MiB nix download buffer, servers have less memory than laptops.
  nix.settings.download-buffer-size = 134217728;

  # Don't build documentation on servers.
  documentation.enable = false;
  documentation.man.enable = false;
  documentation.info.enable = false;
  documentation.nixos.enable = false;
  documentation.doc.enable = false;
  documentation.dev.enable = false;
}
