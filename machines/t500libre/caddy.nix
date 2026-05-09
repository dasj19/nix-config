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
  webmaster-email = gitSecrets.gnuDomainWebmaster;
  archive-ip = gitSecrets.t500libreLanIp;
  ideapad-ip = gitSecrets.ideapad100LanIp;
in
{
  sops.secrets.root_password = { };

  # PHP-FPM pools.
  # https://discourse.nixos.org/t/502-bad-gateway-with-caddy-and-php-fastcgi/25429
  services.phpfpm.pools."php84" = {
    user = "caddy";
    group = "caddy";
    phpPackage = pkgs.php84.buildEnv {
      extensions =
        {
          enabled,
          all,
        }:
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
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.max_requests" = 500;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
      "php_admin_flag[log_errors]" = "on";
      "catch_workers_output" = true;
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

  # Archivebox.
  #  services.caddy.virtualHosts."archive.${gnu-domain}".extraConfig = ''
  #    redir https://archive.${gnu-domain}{uri} permanent
  #  '';
  #  services.caddy.virtualHosts."https://archive.${gnu-domain}:443".extraConfig = ''
  #    root * /var/www/archive.${gnu-domain}
  #    file_server
  #    php_fastcgi unix/${config.services.phpfpm.pools.php84.socket}
  #  '';
  #
  #  # ACME settings for the archive domain.
  #  # (https://aottr.dev/posts/2024/08/homelab-setting-up-caddy-reverse-proxy-with-ssl-on-nixos/)
  #  security.acme.certs."archive.${gnu-domain}" = {
  #    inherit (config.services.caddy) group;
  #
  #    domain = "archive.${gnu-domain}";
  #    extraDomainNames = [ "www.archive.${gnu-domain}" ];
  #  };


  # Apache webserver with virtual hosts. @todo: migrate to caddy.
  # @todo: harden caddy like apache was with the conf below, or discard settings that no longer make sense.
  #  services.httpd = {
  #    enable = true;

  # https://raymii.org/s/tutorials/Strong_SSL_Security_On_Apache2.html
  #    sslProtocols = "-all +TLSv1.3 +TLSv1.2";
  # https://gist.github.com/GAS85/42a5469b32659a0aecc60fa2d4990308
  #    sslCiphers = "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256";

  # Disable access and error logs and per-host logging.
  #    logFormat = "none";
  #
  # Apache webserver with virtual hosts. @todo: migrate to caddy.
  # @todo: harden caddy like apache was with the conf below, or discard settings that no longer make sense.
  #  services.httpd = {
  #    enable = true;

  # https://raymii.org/s/tutorials/Strong_SSL_Security_On_Apache2.html
  #    sslProtocols = "-all +TLSv1.3 +TLSv1.2";
  # https://gist.github.com/GAS85/42a5469b32659a0aecc60fa2d4990308
  #    sslCiphers = "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256";

  # Disable access and error logs and per-host logging.
  #    logFormat = "none";
  #    logPerVirtualHost = false;

  #    virtualHosts = {
  # Use only for SSL certificates. The mailserver should take care of the rest.
  #      "mail.${gnu-domain}" = {
  #        enableACME = true;
  #        forceSSL = true;
  #      };
  # The Archive box instance.
  #      "archive.${gnu-domain}" = {
  #        enableACME = true;
  #        forceSSL = true;
  #        hostName = "archive.${gnu-domain}";
  #        serverAliases = [
  #          "www.archive.${gnu-domain}"
  #        ];
  #        documentRoot = "/var/www/archive.${gnu-domain}/";
  #        logFormat = "combined";
  #        extraConfig = ''
  #          <LocationMatch "/">
  # Proxy the archivebox instance from the local network.
  #ProxyPreserveHost On
  #            ProxyPass http://${archive-ip}:8000/
  #            ProxyPassReverse http://${archive-ip}:8000/

  # Headers passed to the proxy.
  #RequestHeader set X-CSP-Nonce: "%{CSP_NONCE}e"
  # Relax CSP for admin paths.

  # @TODO: Slowly enable more and more CSP attributes: https://content-security-policy.com/
  #           Header unset Content-Security-Policy
  #           Header unset Clear-Site-Data
  # Allow framing of the archive site.
  #           Header unset X-Frame-Options
  #         </LocationMatch>
  #       '';
  #     };
  # Task planning tool.
  #     "do.${gnu-domain}" = {
  # forceSSL uses 302 Found redirects, using own 301 redirects in 'extraConfig'.
  #addSSL = true;
  #       enableACME = true;
  #       #inherit acmeRoot;
  #       forceSSL = true;
  #       hostName = "do.${gnu-domain}";
  #       documentRoot = "/var/www/do.${gnu-domain}/public/";
  # serving php files as default.
  #       locations."/".index = "index.php";
  #       extraConfig = ''
  #         <Directory "/var/www/do.${gnu-domain}/public/">
  # Turn on URL rewriting
  #           RewriteEngine On
  #           RewriteBase /
  # Allow any files or directories that exist to be displayed directly
  #           RewriteCond %{REQUEST_FILENAME} !-f
  #           RewriteCond %{REQUEST_FILENAME} !-d

  # Rewrite all other URLs to index.php/
  #           RewriteRule .* index.php/''$0 [PT,L]
  #         </Directory>
  #         <LocationMatch "/">
  # @TODO: Slowly enable more and more CSP attributes: https://content-security-policy.com/
  #           Header unset Content-Security-Policy
  #           Header unset Clear-Site-Data
  # Allow framing of the archive site.
  #           Header unset X-Frame-Options
  #         </LocationMatch>
  #        '';
  #      };
  # @todo: make an overall map of the services hosted at the gnu domain.
  #      "${gnu-domain}" = {
  # forceSSL uses 302 Found redirects, using own 301 redirects in 'extraConfig'.
  #addSSL = true;
  #        enableACME = true;
  #inherit acmeRoot;
  #        forceSSL = true;
  #        hostName = gnu-domain;
  #        serverAliases = [
  #          "www.${gnu-domain}"
  #        ];
  #        documentRoot = "/var/www/${gnu-domain}/";
  #      };
  #    };
  #    extraConfig = ''
  #      <Directory /var/www>
  #        Options Indexes FollowSymLinks MultiViews
  #        AllowOverride All
  #        Order allow,deny
  #        allow from all
  #      </Directory>

  # These headers were validated with the following online checkers:
  # https://observatory.mozilla.org/analyze/<domain>
  # https://www.serpworx.com/check-security-headers/?url=<domain>
  # https://geekflare.com/tools/secure-headers-test
  # https://tools.keycdn.com/curl
  # https://devcodes.dev/tools/headers-security
  # https://www.atatus.com/tools/security-header#url=https://<domain>
  # https://www.vulnerar.com/scans/http-security-header

  # Change the default Server header that usually contains the version of the Apache server.
  # https://httpd.apache.org/docs/2.4/mod/core.html#servertokens
  #      ServerTokens Prod

  # Setting specific SSL Curves.
  # https://raymii.org/s/tutorials/Strong_SSL_Security_On_Apache2.html
  #SSLOpenSSLConfCmd Curves X25519:secp521r1:secp384r1:prime256v1

  # Enable and configure OCSP Stapling.
  # https://raymii.org/s/tutorials/OCSP_Stapling_on_Apache2.html
  #      SSLUseStapling on
  #      SSLStaplingCache "shmcb:logs/stapling-cache(150000)"
  #      SSLStaplingResponseMaxAge 900

  # Disallow non-SNI clients to access the virtual hosts.
  # NOTE: this renders very old browsers from the WinXP era unusable with the current site.
  # https://docs.rackspace.com/support/how-to/using-sni-to-host-multiple-ssl-certificates-in-apache/
  # https://httpd.apache.org/docs/current/mod/mod_ssl.html
  #      SSLStrictSNIVHostCheck on

  # Enable HSTS over HTTPS only
  # @see https://https.cio.gov/hsts/
  # @see https://hstspreload.org/
  #      Header always set Strict-Transport-Security: "max-age=31536000; includeSubDomains; preload" env=HTTPS

  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin
  #      Header set Access-Control-Allow-Origin: *

  # https://infosec.mozilla.org/guidelines/web_security#x-frame-options
  # Prevent website from framing this site.
  #      Header set X-Frame-Options: "DENY"

  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-XSS-Protection
  # Prevent XSS in older browsers that don't support CSP.
  #      Header set X-XSS-Protection "1; mode=block"

  # https://sersart.com/x-permitted-cross-domain-policies/
  # Prevent embedding our resources in Adobe products (PDF, flashplayer)
  #      Header set X-Permitted-Cross-Domain-Policies "none"

  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Content-Type-Options
  # Prevent MIME type sniffing attacks.
  #      Header set X-Content-Type-Options "nosniff"

  # https://infosec.mozilla.org/guidelines/web_security#content-security-policy
  # https://content-security-policy.com/
  # TODO: add require-trusted-types-for 'script'; and change the scripts to abide by the rules.
  #      Header set Content-Security-Policy: "default-src 'none'; frame-ancestors 'none'; script-src https:; connect-src 'self'; img-src * data: ; style-src 'self' 'report-sample'; base-uri 'self'; form-action 'self'; font-src 'self'; upgrade-insecure-requests;"

  # https://www.permissionspolicy.com/
  #      Header set Permissions-Policy: "accelerometer=(), ambient-light-sensor=(), autoplay=(), battery=(), camera=(), cross-origin-isolated=(), display-capture=*, document-domain=(), encrypted-media=(), execution-while-not-rendered=(), execution-while-out-of-viewport=(), fullscreen=*, geolocation=(), gyroscope=(), magnetometer=(), microphone=(), midi=(), navigation-override=(), payment=(), picture-in-picture=*, publickey-credentials-get=(), screen-wake-lock=(), sync-xhr=(), usb=(), web-share=(), xr-spatial-tracking=(), clipboard-read=*, clipboard-write=*, gamepad=(), speaker-selection=(), conversion-measurement=(), focus-without-user-activation=(), hid=(), idle-detection=(), interest-cohort=(), serial=(), sync-script=(), trust-token-redemption=(), vertical-scroll=()"

  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy
  # Do not allows referrer information when protocol is downgraded.
  #      Header set Referrer-Policy "no-referrer-when-downgrade"

  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Feature-Policy
  # Deprecated header that disables most features.
  #      Header set Feature-Policy "camera 'none'; accelerometer 'none'; ambient-light-sensor 'none'; autoplay 'none'; camera 'none'; document-domain 'none'; encrypted-media 'none'; fullscreen 'self'; geolocation 'none'; gyroscope 'none'; layout-animations 'none'; lazyload 'none'; legacy-image-formats 'none'; magnetometer 'none'; midi 'none'; oversized-images 'none'; payment 'none'; picture-in-picture 'none'; speaker-selection 'none'; sync-script 'none'; sync-xhr 'none'; unoptimized-images 'none'; unsized-media 'none'; usb 'none'; vr 'none';"

  # Control which caches the browsers will clear. We ask for all caches to be cleared.
  #      Header set Clear-Site-Data '"*"'
  #      Header set Cache-Control "no-cache"

  # Allowing all Cross Origins.
  #      Header set Cross-Origin-Embedder-Policy "unsafe-none"
  #      Header set Cross-Origin-Opener-Policy "unsafe-none"
  #      Header set Cross-Origin-Resource-Policy "cross-origin"

  # Headers not supported by choice:
  #  * HTTP Public Key Pinning (HPKP); https://raymii.org/s/articles/HTTP_Public_Key_Pinning_Extension_HPKP.html

  # Note about risky security headers: https://www.tunetheweb.com/blog/dangerous-web-security-features/

  # https://docs.rackspace.com/support/how-to/using-sni-to-host-multiple-ssl-certificates-in-apache/
  # TODO: Check after December 7 to see if SNI is active
  # Listen for virtual host requests on all IP addresses
  # NameVirtualHost *:443

  # Accept connections for these virtual hosts from non-SNI clients
  #      SSLStrictSNIVHostCheck off

  # Enable SSL stapling.
  #      SSLUseStapling on

  #      SSLStaplingCache shmcb:/tmp/stapling_cache(128000)
  #    '';
  #  };
}
