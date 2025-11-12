{
  config,
  pkgs,
  gitSecrets,
  ...
}: let
  # Git secrets.
  gnu-domain = gitSecrets.gnuDomain;
  name-domain = gitSecrets.nameDomain;
  webmaster-email = gitSecrets.gnuDomainWebmaster;
  archive-ip = gitSecrets.gnuArchiveIp;
in {
  sops.secrets.root_password = {};

  # Nextcloud instance.
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    hostName = "localhost";
    config.adminpassFile = config.sops.secrets.root_password.path;
  };
  services.nextcloud.settings = {
    force_language = "ro";
  };
  services.nextcloud.config.dbtype = "sqlite";
  services.nextcloud.settings.trusted_domains = [
    "familia.${name-domain}"
  ];
  services.nextcloud.settings.overwriteprotocol = "https";
  services.nginx.virtualHosts."${config.services.nextcloud.hostName}".listen = [
    {
      addr = "127.0.0.1";
      port = 8001;
    }
  ];

  # Apache webserver with virtual hosts. @todo: migrate to caddy.
  services.httpd = {
    enable = true;
    enablePHP = true;
    phpPackage = pkgs.php84.buildEnv {
      extensions = {
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
    adminAddr = "${webmaster-email}";
    extraModules = [
      "headers"
      "proxy"
      "proxy_http"
      "proxy_uwsgi"
      # 3rd party apache2 modules.
      {
        name = "cspnonce";
        path = "${pkgs.apacheHttpdPackages.mod_cspnonce}/modules/mod_cspnonce.so";
      }
    ];
    maxClients = 1000;

    # https://raymii.org/s/tutorials/Strong_SSL_Security_On_Apache2.html
    sslProtocols = "-all +TLSv1.3 +TLSv1.2";
    # https://gist.github.com/GAS85/42a5469b32659a0aecc60fa2d4990308
    sslCiphers = "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256";

    # Disable access and error logs and per-host logging.
    logFormat = "none";
    logPerVirtualHost = false;

    virtualHosts = {
      # Use only for SSL certificates. The mailserver should take care of the rest.
      "mail.${gnu-domain}" = {
        enableACME = true;
        forceSSL = true;
      };
      # Search engine instance.
      "searx.${gnu-domain}" = {
        enableACME = true;
        forceSSL = true;
        hostName = "searx.${gnu-domain}";
        serverAliases = [
          "www.searx.${gnu-domain}"
        ];
        documentRoot = "/var/www/searx.${gnu-domain}/";
        logFormat = "combined";
        extraConfig = ''
          <LocationMatch "/">
            # Proxy the searx instance.
            #ProxyPreserveHost On
            ProxyPass http://127.0.0.1:8100/
            ProxyPassReverse http://127.0.0.1:8100/

            # Headers passed to the proxy.
            RequestHeader set X-CSP-Nonce: "%{CSP_NONCE}e"
          </LocationMatch>
        '';
      };
      # The Archive box instance.
      "archive.${gnu-domain}" = {
        enableACME = true;
        forceSSL = true;
        hostName = "archive.${gnu-domain}";
        serverAliases = [
          "www.archive.${gnu-domain}"
        ];
        documentRoot = "/var/www/archive.${gnu-domain}/";
        logFormat = "combined";
        extraConfig = ''
          <LocationMatch "/">
            # Proxy the archivebox instance from the local network.
            #ProxyPreserveHost On
            ProxyPass http://${archive-ip}:8000/
            ProxyPassReverse http://${archive-ip}:8000/

            # Headers passed to the proxy.
            #RequestHeader set X-CSP-Nonce: "%{CSP_NONCE}e"
            # Relax CSP for admin paths.

            # @TODO: Slowly enable more and more CSP attributes: https://content-security-policy.com/
            Header unset Content-Security-Policy
            Header unset Clear-Site-Data
            # Allow framing of the archive site.
            Header unset X-Frame-Options
          </LocationMatch>
        '';
      };
      # Nextcloud.
      "familia.${name-domain}" = {
        enableACME = true;
        forceSSL = true;
        hostName = "familia.${name-domain}";
        #serverAliases = [
        #  "www.archive.${name-domain}"
        #];
        documentRoot = "/var/www/familia.${name-domain}/";
        logFormat = "combined";
        extraConfig = ''
          <LocationMatch "/">
            # Proxy the archivebox instance from the local network.
            ProxyPreserveHost On
            ProxyPass http://localhost:8001/
            ProxyPassReverse http://localhost:8001/

            # Headers passed to the proxy.
            #RequestHeader set X-CSP-Nonce: "%{CSP_NONCE}e"
            # Relax CSP for admin paths.

            # @TODO: Slowly enable more and more CSP attributes: https://content-security-policy.com/
            Header unset Content-Security-Policy
            Header unset Clear-Site-Data
            # Allow framing of the archive site.
            Header unset X-Frame-Options
          </LocationMatch>
        '';
      };
      # Debian Source List Generator for the masses.
      "dslg.${gnu-domain}" = {
        # forceSSL uses 302 Found redirects, using own 301 redirects in 'extraConfig'.
        #addSSL = true;
        enableACME = true;
        #inherit acmeRoot;
        forceSSL = true;
        hostName = "dslg.${gnu-domain}";
        serverAliases = [
          "www.dslg.${gnu-domain}"
        ];
        documentRoot = "/var/www/dslg.${gnu-domain}/";
        # serving php files as default.
        locations."/".index = "index.php";
      };
      # Task planning tool.
      "do.${gnu-domain}" = {
        # forceSSL uses 302 Found redirects, using own 301 redirects in 'extraConfig'.
        #addSSL = true;
        enableACME = true;
        #inherit acmeRoot;
        forceSSL = true;
        hostName = "do.${gnu-domain}";
        documentRoot = "/var/www/do.${gnu-domain}/public/";
        # serving php files as default.
        locations."/".index = "index.php";
        extraConfig = ''
          <Directory "/var/www/do.${gnu-domain}/public/">
            # Turn on URL rewriting
            RewriteEngine On
            RewriteBase /
            # Allow any files or directories that exist to be displayed directly
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteCond %{REQUEST_FILENAME} !-d

            # Rewrite all other URLs to index.php/
            RewriteRule .* index.php/''$0 [PT,L]
          </Directory>
          <LocationMatch "/">
            # @TODO: Slowly enable more and more CSP attributes: https://content-security-policy.com/
            Header unset Content-Security-Policy
            Header unset Clear-Site-Data
            # Allow framing of the archive site.
            Header unset X-Frame-Options
          </LocationMatch>
        '';
      };
      # Overall map of the services hosted at the gnu domain.
      "${gnu-domain}" = {
        # forceSSL uses 302 Found redirects, using own 301 redirects in 'extraConfig'.
        #addSSL = true;
        enableACME = true;
        #inherit acmeRoot;
        forceSSL = true;
        hostName = gnu-domain;
        serverAliases = [
          "www.${gnu-domain}"
        ];
        documentRoot = "/var/www/${gnu-domain}/";
      };
    };
    extraConfig = ''
      <Directory /var/www>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Order allow,deny
        allow from all
      </Directory>

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
      ServerTokens Prod

      # Setting specific SSL Curves.
      # https://raymii.org/s/tutorials/Strong_SSL_Security_On_Apache2.html
      #SSLOpenSSLConfCmd Curves X25519:secp521r1:secp384r1:prime256v1

      # Enable and configure OCSP Stapling.
      # https://raymii.org/s/tutorials/OCSP_Stapling_on_Apache2.html
      SSLUseStapling on
      SSLStaplingCache "shmcb:logs/stapling-cache(150000)"
      SSLStaplingResponseMaxAge 900

      # Disallow non-SNI clients to access the virtual hosts.
      # NOTE: this renders very old browsers from the WinXP era unusable with the current site.
      # https://docs.rackspace.com/support/how-to/using-sni-to-host-multiple-ssl-certificates-in-apache/
      # https://httpd.apache.org/docs/current/mod/mod_ssl.html
      SSLStrictSNIVHostCheck on

      # Enable HSTS over HTTPS only
      # @see https://https.cio.gov/hsts/
      # @see https://hstspreload.org/
      Header always set Strict-Transport-Security: "max-age=31536000; includeSubDomains; preload" env=HTTPS

      # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin
      Header set Access-Control-Allow-Origin: *

      # https://infosec.mozilla.org/guidelines/web_security#x-frame-options
      # Prevent website from framing this site.
      Header set X-Frame-Options: "DENY"

      # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-XSS-Protection
      # Prevent XSS in older browsers that don't support CSP.
      Header set X-XSS-Protection "1; mode=block"

      # https://sersart.com/x-permitted-cross-domain-policies/
      # Prevent embedding our resources in Adobe products (PDF, flashplayer)
      Header set X-Permitted-Cross-Domain-Policies "none"

      # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Content-Type-Options
      # Prevent MIME type sniffing attacks.
      Header set X-Content-Type-Options "nosniff"

      # https://infosec.mozilla.org/guidelines/web_security#content-security-policy
      # https://content-security-policy.com/
      # TODO: add an endpoint for: report-uri https://searx.${gnu-domain}/about https://${gnu-domain};
      # TODO: add require-trusted-types-for 'script'; and change the scripts to abide by the rules.
      # TODO: use something like: "script-src 'nonce-%{CSP_NONCE}e' 'strict-dynamic' https:;" and find a way to nonce-secure the searx instance
      Header set Content-Security-Policy: "default-src 'none'; frame-ancestors 'none'; script-src https:; connect-src 'self'; img-src * data: ; style-src 'self' 'report-sample'; base-uri 'self'; form-action 'self'; font-src 'self'; upgrade-insecure-requests;"

      # https://www.permissionspolicy.com/
      Header set Permissions-Policy: "accelerometer=(), ambient-light-sensor=(), autoplay=(), battery=(), camera=(), cross-origin-isolated=(), display-capture=*, document-domain=(), encrypted-media=(), execution-while-not-rendered=(), execution-while-out-of-viewport=(), fullscreen=*, geolocation=(), gyroscope=(), magnetometer=(), microphone=(), midi=(), navigation-override=(), payment=(), picture-in-picture=*, publickey-credentials-get=(), screen-wake-lock=(), sync-xhr=(), usb=(), web-share=(), xr-spatial-tracking=(), clipboard-read=*, clipboard-write=*, gamepad=(), speaker-selection=(), conversion-measurement=(), focus-without-user-activation=(), hid=(), idle-detection=(), interest-cohort=(), serial=(), sync-script=(), trust-token-redemption=(), vertical-scroll=()"

      # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy
      # Do not allows referrer information when protocol is downgraded.
      Header set Referrer-Policy "no-referrer-when-downgrade"

      # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Feature-Policy
      # Deprecated header that disables most features.
      Header set Feature-Policy "camera 'none'; accelerometer 'none'; ambient-light-sensor 'none'; autoplay 'none'; camera 'none'; document-domain 'none'; encrypted-media 'none'; fullscreen 'self'; geolocation 'none'; gyroscope 'none'; layout-animations 'none'; lazyload 'none'; legacy-image-formats 'none'; magnetometer 'none'; midi 'none'; oversized-images 'none'; payment 'none'; picture-in-picture 'none'; speaker-selection 'none'; sync-script 'none'; sync-xhr 'none'; unoptimized-images 'none'; unsized-media 'none'; usb 'none'; vr 'none';"

      # Control which caches the browsers will clear. We ask for all caches to be cleared.
      Header set Clear-Site-Data '"*"'
      Header set Cache-Control "no-cache"

      # Allowing all Cross Origins.
      Header set Cross-Origin-Embedder-Policy "unsafe-none"
      Header set Cross-Origin-Opener-Policy "unsafe-none"
      Header set Cross-Origin-Resource-Policy "cross-origin"

      # Headers not supported by choice:
      #  * HTTP Public Key Pinning (HPKP); https://raymii.org/s/articles/HTTP_Public_Key_Pinning_Extension_HPKP.html

      # Note about risky security headers: https://www.tunetheweb.com/blog/dangerous-web-security-features/


      # https://docs.rackspace.com/support/how-to/using-sni-to-host-multiple-ssl-certificates-in-apache/
      # TODO: Check after December 7 to see if SNI is active
      # Listen for virtual host requests on all IP addresses
      # NameVirtualHost *:443

      # Accept connections for these virtual hosts from non-SNI clients
      SSLStrictSNIVHostCheck off

      # Enable SSL stapling.
      SSLUseStapling on

      SSLStaplingCache shmcb:/tmp/stapling_cache(128000)
    '';
  };
}
