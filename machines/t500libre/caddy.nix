# @todo: update the archive project, can be moved to ideapad100 (because it already deals with python)
# @todo: make an overall map of the services hosted at the gnu domain.
{
  config,
  pkgs,
  gitSecrets,
  ...
}:
let
  # Git secrets.
  gnu-domain = gitSecrets.gnuDomain;
  name-domain = gitSecrets.nameDomain;
  ideapad-ip = gitSecrets.ideapad100LanIp;
in
{
  imports = [ ../../modules/php-fpm.nix ];

  sops.secrets.root_password = { };

  # PHP-FPM pools.
  # https://discourse.nixos.org/t/502-bad-gateway-with-caddy-and-php-fastcgi/25429
  services.phpfpm.pools."php84" = {
    user = "caddy";
    group = "caddy";
    phpPackage = pkgs.php84.buildEnv {
      extensions =
        { enabled, all }:
        enabled
        ++ (with all; [
          # Extensions for leantime.
          bcmath
          ctype
          curl
          dom
          exif
          fileinfo
          filter
          gd
          imagick
          ldap
          mbstring
          opcache
          openssl
          pcntl
          pdo
          session
          tokenizer
          zip
          simplexml
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

  # Caddy virtual hosts.

  # GNU Domain.
  services.caddy.virtualHosts."http://${gnu-domain}".extraConfig = ''
    redir https://${gnu-domain}{uri} permanent
  '';

  services.caddy.virtualHosts."https://www.${gnu-domain}:443".extraConfig = ''
    # https://hstspreload.org/
    header / Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
    redir https://${gnu-domain}{uri} permanent
    file_server
  '';

  services.caddy.virtualHosts."https://${gnu-domain}:443".extraConfig = ''
    # https://hstspreload.org/
    header / Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
    root * /var/www/${gnu-domain}
    file_server
  '';
  # ACME settings for the gnu domain.
  # (https://aottr.dev/posts/2024/08/homelab-setting-up-caddy-reverse-proxy-with-ssl-on-nixos/)
  security.acme.certs."gnu-domain" = {
    inherit (config.services.caddy) group;

    domain = "${gnu-domain}";
    extraDomainNames = [ "www.${gnu-domain}" ];
  };

  # Task planning tool.
  services.caddy.virtualHosts."http://do.${gnu-domain}".extraConfig = ''
    redir https://do.${gnu-domain}{uri} permanent
  '';
  services.caddy.virtualHosts."https://do.${gnu-domain}:443".extraConfig = ''
    root * /var/www/do.${gnu-domain}/public

    # Serve static files if they exist, otherwise pass to PHP
    file_server
    php_fastcgi unix/${config.services.phpfpm.pools.php84.socket}
    log {
      output file /var/log/caddy/https-do-gnu-domain.log
    }
  '';
  # ACME settings for the planning tool domain.
  # (https://aottr.dev/posts/2024/08/homelab-setting-up-caddy-reverse-proxy-with-ssl-on-nixos/)
  security.acme.certs."do-gnu-domain" = {
    inherit (config.services.caddy) group;

    domain = "do.${gnu-domain}";
    extraDomainNames = [ "www.do.${gnu-domain}" ];
  };

  # Media domain.
  services.caddy.virtualHosts."http://media.${name-domain}".extraConfig = ''
    redir https://media.${name-domain}{uri} permanent
  '';
  services.caddy.virtualHosts."https://media.${name-domain}:443".extraConfig = ''
    reverse_proxy ${ideapad-ip}:2283
  '';
  # ACME settings for the media domain.
  # (https://aottr.dev/posts/2024/08/homelab-setting-up-caddy-reverse-proxy-with-ssl-on-nixos/)
  security.acme.certs."media-domain" = {
    inherit (config.services.caddy) group;

    domain = "media.${name-domain}";
    extraDomainNames = [ "www.media.${name-domain}" ];
  };

  # The gen domain (for genealogy).
  services.caddy.virtualHosts."http://gen.${name-domain}".extraConfig = ''
    redir https://gen.${name-domain}{uri} permanent
  '';
  services.caddy.virtualHosts."https://gen.${name-domain}".extraConfig = ''
    reverse_proxy ${ideapad-ip}:8001
  '';
  # ACME settings for the media domain.
  # (https://aottr.dev/posts/2024/08/homelab-setting-up-caddy-reverse-proxy-with->
  security.acme.certs."gen-domain" = {
    inherit (config.services.caddy) group;

    domain = "gen.${name-domain}";
    extraDomainNames = [ "www.gen.${name-domain}" ];
  };

  # ACME settings for the archivebox domain (disabled - @todo re-enable archivebox).
  # security.acme.certs."archive.${gnu-domain}" = {
  #   inherit (config.services.caddy) group;
  #   domain = "archive.${gnu-domain}";
  #   extraDomainNames = [ "www.archive.${gnu-domain}" ];
  # };
}
