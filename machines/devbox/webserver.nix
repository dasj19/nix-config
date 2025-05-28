{ config, pkgs, ... }:

let 

  devbox-domain = "devbox.dev";

in

{
  # Using caddy webserver.
  services.caddy.enable = true;

  services.caddy.globalConfig = ''
    auto_https off
  '';

  # Caddy virtual hosts.
  services.caddy.virtualHosts."http://${devbox-domain}:80".extraConfig = ''
      # Deliver files and interpret php.
      root * /var/www/${devbox-domain}/
      file_server
      php_fastcgi unix/${config.services.phpfpm.pools.php84.socket}
  '';

  # PHP-FPM pools.
  # https://discourse.nixos.org/t/502-bad-gateway-with-caddy-and-php-fastcgi/25429
  services.phpfpm.pools."php84" = {
    user = "caddy";
    group = "caddy";
    phpPackage = pkgs.php84;
    settings = {
      "listen.owner" = config.services.caddy.user;
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.max_requests" = 500;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
      "php_admin_value[error_log]" = "stderr";
      "php_admin_flag[log_errors]" = true;
      "catch_workers_output" = true;
    };
  };
}
