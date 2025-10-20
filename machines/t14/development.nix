{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [

  ];

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };

  # Apache webserver with virtual hosts. @todo: migrate to caddy.
  services.httpd = {
    enable = true;
    enablePHP = true;
    phpPackage = pkgs.php84.buildEnv {
      extensions = { enabled, all }: enabled ++ (with all; [
        amqp
        ctype
        iconv
        intl
        mbstring
        openssl
        pdo_pgsql
        redis
        sodium
        tokenizer
        xsl
        xdebug 
      ]);
      extraConfig = ''
        # Enable opening of files in vscodium.
        xdebug.file_link_format=vscodium://file/%f:%l
      '';
    };
    adminAddr = "admin@localhost";
    extraModules = [
      "headers" "proxy" "proxy_http" "proxy_uwsgi"
    ];
    maxClients = 1000;

    # Disable access and error logs and per-host logging.
    logFormat = "none";
    logPerVirtualHost = false;

    virtualHosts = {
      # Local vCity instance.
      "localhost" = {
        hostName = "localhost";
        documentRoot = "/home/daniel/workspace/projects/spacerace/source";
        logFormat = "combined";
      };
    };
  };
}