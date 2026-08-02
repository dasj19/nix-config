{
  config,
  pkgs,
  ...
}:

{
  imports = [ ../../modules/php-fpm.nix ];

  # PHP-FPM pools.
  # https://discourse.nixos.org/t/502-bad-gateway-with-caddy-and-php-fastcgi/25429
  services.phpfpm.pools."php85" = {
    user = "caddy";
    group = "caddy";
    phpPackage = pkgs.php85.buildEnv {
      extensions =
        { enabled, all }:
        enabled
        ++ (with all; [
          # Extensions for genealogy.
          exif
          gd
          intl
          pcov
          xsl
        ]);
    };

    settings = {
      "listen.owner" = config.services.caddy.user;
    }
    // config.services.phpfpm.defaultPoolSettings
    // {
      "php_admin_flag[log_errors]" = "on";
      "php_flag[display_errors]" = "on";
    };
  };

  # Using caddy webserver.
  services.caddy.enable = true;
  services.caddy.globalConfig = ''
    servers {
      protocols h1 h2 h3
    }
  '';

  # Genealogy running http on :8001.
  services.caddy.virtualHosts.":8001".extraConfig = ''
    root * /var/www/genealogy/public
    file_server
    php_fastcgi unix/${config.services.phpfpm.pools.php85.socket}
  '';

}
