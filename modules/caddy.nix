# caddy: response headers shared by every Caddy virtual host.
# scope: servers running Caddy
#
# Extends the virtualHosts submodule, so each host gets these lines prepended
# to its extraConfig without repeating them in the host block.

{ lib, ... }:

{
  options.services.caddy.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        # Replaces the default "Server: Caddy", deferred with ">" so it also
        # overrides the Server header sent by reverse-proxied backends.
        config.extraConfig = lib.mkBefore ''
          header >Server "GeekServer 1337"
        '';
      }
    );
  };
}
