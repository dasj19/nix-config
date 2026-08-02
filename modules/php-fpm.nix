# php-fpm: default PHP-FPM pool settings shared across machines.
# Reduces duplication of the common FPM pool 'settings' block.
# Usage: services.phpfpm.pools."name" = { ... // config.services.phpfpm.defaultPoolSettings; };

{ config, lib, ... }:

{
  options.services.phpfpm.defaultPoolSettings = lib.mkOption {
    type =
      with lib.types;
      attrsOf (oneOf [
        str
        int
        bool
      ]);
    default = {
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.max_requests" = 500;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
      "catch_workers_output" = true;
    };
    description = ''
      Default PHP-FPM pool settings shared by all machines.
      The "listen.owner" key is intentionally omitted since it depends on
      config.services.caddy.user which is only available at module evaluation time.
    '';
  };
}
