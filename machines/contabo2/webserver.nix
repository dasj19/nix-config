{
  config,
  gitSecrets,
  pkgs,
  ...
}:

let
  firm-domain = gitSecrets.firmDomain;
  daniel-domain = gitSecrets.danielHackerDomain;
  caddy-browse =  (pkgs.callPackage ../../pkgs/caddy-browse.nix {});
in

{
  # Custom webserver dependencies.
  environment.systemPackages = [
    caddy-browse
  ];

  system.activationScripts.caddyBrowse = {
    text = ''
      mkdir -p /var/lib/caddy
      ln -sf ${caddy-browse}/lib/caddy/browse.html /var/lib/caddy/browse.html
    '';
  };
  
  # Using caddy webserver.
  services.caddy.enable = true;

  # Caddy virtual hosts.
  services.caddy.virtualHosts."www.${firm-domain}".extraConfig = ''
    redir https://${firm-domain}{uri} permanent
  '';
  services.caddy.virtualHosts."${firm-domain}".extraConfig = ''

    root * /var/www/${firm-domain}/web
    file_server
    php_fastcgi unix/${config.services.phpfpm.pools.php82.socket}

  '';
  services.caddy.virtualHosts."www.${daniel-domain}".extraConfig = ''
    redir https://${daniel-domain}{uri} permanent
  '';
  services.caddy.virtualHosts."${daniel-domain}".extraConfig = ''
    root * /var/www/${daniel-domain}

    # Allowed listing paths.
    @listing path /collections/* /collections /papers/* /papers /slides/* /slides

    handle @listing {
      file_server browse
    }

    # Serve static files if they exist, otherwise pass to PHP
    try_files {path} {path}/index.php
    php_fastcgi unix/${config.services.phpfpm.pools.php84.socket}
    file_server
  '';

  # ACME settings for the firm domain.
  # (https://aottr.dev/posts/2024/08/homelab-setting-up-caddy-reverse-proxy-with-ssl-on-nixos/)
  security.acme.certs."${firm-domain}" = {
    inherit (config.services.caddy) group;

    domain = "${firm-domain}";
    extraDomainNames = [ "www.${firm-domain}" ];
    dnsProvider = "cloudflare";
    dnsResolver = "1.1.1.1:53";
    dnsPropagationCheck = true;
  };
  security.acme.certs."${daniel-domain}" = {
    inherit (config.services.caddy) group;

    domain = "${daniel-domain}";
    extraDomainNames = [ "www.${daniel-domain}" ];
    dnsProvider = "cloudflare";
    dnsResolver = "1.1.1.1:53";
    dnsPropagationCheck = true;
  };

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
      "php_admin_value[error_log]" = "stderr";
      "php_admin_flag[log_errors]" = true;
      "catch_workers_output" = true;
    };
  };

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

  # Firm Database.
  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb_114;
  services.mysql.initialScript = pkgs.writeText "setup.sql" ''
    CREATE DATABASE firm;
    GRANT ALL PRIVILEGES ON firm.* TO "firm"@"localhost" IDENTIFIED BY "firm" WITH GRANT OPTION;
  '';

}
