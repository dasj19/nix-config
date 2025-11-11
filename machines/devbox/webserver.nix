{ config, lib, pkgs, ... }:

let 

  devbox-domain = "devbox.dev";

in

{
  # Using caddy webserver.
  services.caddy.enable = true;

  # Caddy virtual hosts.
  services.caddy.virtualHosts."https://${devbox-domain}:443".extraConfig = ''
      # Self-signed certs. In FF about:config the network.stricttransportsecurity.preloadlist (HSTS) needs to be dissabled.
      # Created with: openssl req  -nodes -new -x509  -keyout server.key -out server.cert
      tls "/srv/certs/server.cert" "/srv/certs/server.key"

      # Use php82 with production-like settings for development tools.
      handle /webgrind/* {
        php_fastcgi unix/${config.services.phpfpm.pools.php82.socket}
      }

      # Deliver files and interpret php.
      root * /srv/www/${devbox-domain}/
      file_server
      php_fastcgi unix/${config.services.phpfpm.pools.php84.socket}

  '';

  # PHP-FPM pools.
  # https://discourse.nixos.org/t/502-bad-gateway-with-caddy-and-php-fastcgi/25429
  services.phpfpm.pools."php82" = {
    user = "caddy";
    group = "caddy";
    phpPackage = pkgs.php82;
    settings = {
      "listen.owner" = config.services.caddy.user;
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.max_requests" = 500;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
      "catch_workers_output" = true;
    };
    phpOptions = ''
      # Report errors but do no display them.
      error_reporting=E_ALL
      display_errors=Off
      display_startup_errors=Off
      # Enable error logging to file.
      error_log=/var/log/php82_errors.log
      # Unlimited error length.
      log_errors_max_len=0
      # Increase memory limit.
      memory_limit=512M
      # Increase transfer filesizes.
      post_max_size=100M
      upload_max_filesize=100M
      # Mailcatcher support for php.
      sendmail_path=/run/current-system/sw/bin/catchmail
      sendmail_from=mailcatcher@devbox.dev
    '';
    phpEnv."PATH" = lib.makeBinPath [ pkgs.php82 ];
  };

  services.phpfpm.pools."php84" = {
    user = "caddy";
    group = "caddy";
    phpPackage = pkgs.php84.buildEnv {
      extensions = { enabled, all }: enabled ++ (with all; [
        xdebug
      ]);
      extraConfig = ''
        xdebug.mode=develop,profile
        xdebug.start_with_request=trigger
        xdebug.output_dir=/tmp/cachegrind
      '';
    };
    settings = {
      "listen.owner" = config.services.caddy.user;
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.max_requests" = 500;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
#      "php_admin_value[error_log]" = "stderr";
#      "php_admin_flag[log_errors]" = true;
      "catch_workers_output" = true;
    };
    phpOptions = ''
      # Development settings for php.ini.
      # Displaying errors to browser.
      error_reporting=E_ALL
      display_errors=On
      display_startup_errors=On
      # Enable error logging to file.
      error_log=/var/log/php84_errors.log
      # Unlimited error length.
      log_errors_max_len=0
      # Increase memory limit.
      memory_limit=512M
      # Increase transfer filesizes.
      post_max_size=100M
      upload_max_filesize=100M
      # Mailcatcher support for php.
      sendmail_path=/run/current-system/sw/bin/catchmail
      sendmail_from=mailcatcher@devbox.dev
    '';
    phpEnv."PATH" = lib.makeBinPath [ pkgs.php84 ];
  };
  # Allow php to access the system's /tmp folder instead of systemd isolated tmp.
  systemd.services.phpfpm-php82.serviceConfig.PrivateTmp = lib.mkForce false;
  systemd.services.phpfpm-php84.serviceConfig.PrivateTmp = lib.mkForce false;

  # Mailcatcher.
  services.mailcatcher.enable = true;
  services.mailcatcher.http.ip = "0.0.0.0";
}
