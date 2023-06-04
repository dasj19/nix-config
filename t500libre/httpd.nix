{ config, lib, pkgs, ... }:

let
    # Using this repeatedly in every virtual host because a global redirect is not currently posssible.
    redirect-rules = ''
      # Generic redirect www to non-www for all the domains on the server.
      RewriteEngine On
      RewriteOptions Inherit
      RewriteCond %{HTTP_HOST} ^www\.(.+)$ [NC]
      RewriteRule ^/(.*) https://%1/''$1 [R=301,L]
    '';

  # Agenix strings:
  webmaster-email = lib.strings.fileContents config.age.secrets.webserver-account-webmaster-email.path;
  gnu-ip = lib.strings.fileContents config.age.secrets.webserver-virtualhost-gnu-ip.path;
  gnu-domain = lib.strings.fileContents config.age.secrets.webserver-virtualhost-gnu-domain.path;
  archive-ip = lib.strings.fileContents config.age.secrets.webserver-virtualhost-archive-ip.path;
  firstguest-ip = lib.strings.fileContents config.age.secrets.webserver-virtualhost-firstguest-ip.path;
  firstguest-domain = lib.strings.fileContents config.age.secrets.webserver-virtualhost-firstguest-domain.path;
  secondguest-ip = lib.strings.fileContents config.age.secrets.webserver-virtualhost-secondguest-ip.path;
  secondguest-domain = lib.strings.fileContents config.age.secrets.webserver-virtualhost-secondguest-domain.path;
  # Agenix paths:

in

{
   # Agenix secrets.
  age.secrets.webserver-account-webmaster-email.file = secrets/webserver-account-webmaster-email.age;
  age.secrets.webserver-virtualhost-gnu-ip.file = secrets/webserver-virtualhost-gnu-ip.age;
  age.secrets.webserver-virtualhost-gnu-domain.file = secrets/webserver-virtualhost-gnu-domain.age;
  age.secrets.webserver-virtualhost-archive-ip.file = secrets/webserver-virtualhost-archive-ip.age;
  age.secrets.webserver-virtualhost-firstguest-ip.file = secrets/webserver-virtualhost-firstguest-ip.age;
  age.secrets.webserver-virtualhost-firstguest-domain.file = secrets/webserver-virtualhost-firstguest-domain.age;
  age.secrets.webserver-virtualhost-secondguest-ip.file = secrets/webserver-virtualhost-secondguest-ip.age;
  age.secrets.webserver-virtualhost-secondguest-domain.file = secrets/webserver-virtualhost-secondguest-domain.age;


  services.httpd = {
    enable = true;
    enablePHP = true;
    adminAddr = webmaster-email;
    extraModules = [
      "proxy" "headers" "proxy_uwsgi"
      # 3rd party apache2 modules.
      { name = "cspnonce"; path = "${pkgs.apacheHttpdPackages.mod_cspnonce}/modules/mod_cspnonce.so"; }
    ];
    maxClients = 1000;

    # https://raymii.org/s/tutorials/Strong_SSL_Security_On_Apache2.html
    sslProtocols = "-all +TLSv1.3 +TLSv1.2";
    # https://gist.github.com/GAS85/42a5469b32659a0aecc60fa2d4990308
    sslCiphers = "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256";

    # Disable access and error logs and per-host logging.
    # logFormat = "none";
    # logPerVirtualHost = false;

    virtualHosts = {
      # Exposing the main domain content when accessing directly by IP.
      "ip-based" = {
        addSSL = true;
        hostName = gnu-ip;
        documentRoot = "/var/www/${gnu-domain}/";
        # Using self signed certificate.
        sslServerCert = "/var/www/localhost.crt";
        sslServerKey = "/var/www/localhost.key";
      };
      # Use only for SSL certificates. The mailserver should take care of the rest.
      "mail.${gnu-domain}" = {
        forceSSL = true;
        enableACME = true;
      };
      # Search engine instance.
      "searx.${gnu-domain}" = {
        forceSSL = true;
        enableACME = true;
        hostName = "searx.${gnu-domain}";
        serverAliases = [
          "www.searx.${gnu-domain}"
        ]; 
        documentRoot = "/var/www/searx.${gnu-domain}/";
        logFormat = "combined";
        extraConfig = ''
          # Redirects.
          ${redirect-rules}
          # Forward traffic to a modified opensearch.xml. (Mainly added support for https links)
          Alias  "/opensearch.xml" "/var/www/searx.${gnu-domain}/opensearch.xml"
          ProxyPassMatch "\/opensearch\.xml" "!"

          # Forward traffic for robots.txt and sitemap.xml
          Alias  "/robots.txt" "/var/www/searx.${gnu-domain}/robots.txt"
          ProxyPassMatch "\/robots\.txt" "!"
          Alias  "/sitemap.xml" "/var/www/searx.${gnu-domain}/sitemap.xml"
          ProxyPassMatch "\/sitemap\.xml" "!"

          <LocationMatch "/">
            # Proxy the searx instance.
            #ProxyPreserveHost On
            ProxyPass http://127.0.0.1:4004/
            ProxyPassReverse http://127.0.0.1:4004/

            # Headers passed to the proxy.
            RequestHeader set X-CSP-Nonce: "%{CSP_NONCE}e"
          </LocationMatch>
        '';
      };
      # The Archive box instance.
      "archive.${gnu-domain}" = {
        forceSSL = true;
        enableACME = true;
        hostName = "archive.${gnu-domain}";
        serverAliases = [
          "www.archive.${gnu-domain}"
        ]; 
        documentRoot = "/var/www/archive.${gnu-domain}/";
        logFormat = "combined";
        extraConfig = ''
          # Redirects.
          ${redirect-rules}

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
          </LocationMatch>
        '';
      };
      
      # Debian Souce List Generator for the masses.
      "dslg.${gnu-domain}" = {
        forceSSL = true;
        enableACME = true;
        hostName = "dslg.${gnu-domain}";
        serverAliases = [
          "www.dslg.${gnu-domain}"
        ];
        documentRoot = "/var/www/dslg.${gnu-domain}/";
        # serving php files as default.
        locations."/".index = "index.php";
        extraConfig = ''
          # Redirects.
          ${redirect-rules}
        '';
      };
      # Overall map of the services hosted at the gnu domain.
      "${gnu-domain}" = {
        forceSSL = true;
        enableACME = true;
        hostName = gnu-domain;
        serverAliases = [
          "www.${gnu-domain}"
        ];
        documentRoot = "/var/www/${gnu-domain}/"; # "/var/www/gnu-domain/"
        extraConfig = ''
          # Redirects.
          ${redirect-rules}
        '';
      };

      # The first guest domain.
      "${firstguest-domain}" = {
        forceSSL = true;
        enableACME = true;
        hostName = "${firstguest-domain}";
        serverAliases = [
          "www.${firstguest-domain}"
        ]; 
        documentRoot = "/var/www/${firstguest-domain}/";
        logFormat = "combined";
        extraConfig = ''
          # Redirects.
          ${redirect-rules}

          <Proxy *>
            Order deny,allow
            Allow from all
          </Proxy>

          ProxyPreserveHost On
          SSLProxyEngine on
           # Proxy the wordpress instance from the local network.
           #ProxyPreserveHost On
           ProxyPass / http://${firstguest-ip}:10001/
           ProxyPassReverse / http://${firstguest-ip}:10001/

           # Send "Proxy" headers.
           RequestHeader set X-Forwarded-Proto "https"
           RequestHeader set X-Forwarded-Port "443"

          <LocationMatch "/">
            # Disable most of the security headers for this host.
            Header unset Content-Security-Policy
            Header unset Permissions-Policy
            Header unset X-Frame-Options
            Header unset X-Permitted-Cross-Domain-Policies
            Header unset Feature-Policy
            Header unset Clear-Site-Data
            Header unset Expect-CT
            Header unset Cross-Origin-Embedder-Policy 
            Header unset Cross-Origin-Opener-Policy
            Header unset Cross-Origin-Resource-Policy
          </LocationMatch>
        '';
      };

      # The second guest domain.
      "${secondguest-domain}" = {
        forceSSL = true;
        enableACME = true;
        hostName = "${secondguest-domain}";
        serverAliases = [
          "www.${secondguest-domain}"
        ]; 
        documentRoot = "/var/www/${secondguest-domain}/";
        logFormat = "combined";
        extraConfig = ''
          # Redirects.
          ${redirect-rules}

          <Proxy *>
            Order deny,allow
            Allow from all
          </Proxy>

          ProxyPreserveHost On
          SSLProxyEngine on
           # Proxy the wordpress instance from the local network.
           #ProxyPreserveHost On
           ProxyPass / http://${secondguest-ip}:10002/
           ProxyPassReverse / http://${secondguest-ip}:10002/

           # Send "Proxy" headers.
           RequestHeader set X-Forwarded-Proto "https"
           RequestHeader set X-Forwarded-Port "443"
          <LocationMatch "/">

            # Disable most of the security headers for this host.
            Header unset Content-Security-Policy
            Header unset Permissions-Policy
            Header unset X-Frame-Options
            Header unset X-Permitted-Cross-Domain-Policies
            Header unset Feature-Policy
            Header unset Clear-Site-Data
            Header unset Expect-CT
            Header unset Cross-Origin-Embedder-Policy
            Header unset Cross-Origin-Opener-Policy
            Header unset Cross-Origin-Resource-Policy
          </LocationMatch>
        '';
      };
    };


    extraConfig = ''
      <Directory /var/www>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Order allow,deny
        allow from all
      </Directory>

      # These headers were vaildated with the following online checkers:
      # https://observatory.mozilla.org/analyze/<domain>
      # https://www.serpworx.com/check-security-headers/?url=<domain>
      # https://geekflare.com/tools/secure-headers-test
      # https://tools.keycdn.com/curl
      # https://devcodes.dev/tools/headers-security
      # https://www.atatus.com/tools/security-header#url=https://<domain>
      # https://www.vulnerar.com/scans/http-security-header

      # Change the default Server header that usually cotains the version of the Apache server.
      # https://httpd.apache.org/docs/2.4/mod/core.html#servertokens
      ServerTokens Prod

      # Setting specific SSL Curves.
      # https://raymii.org/s/tutorials/Strong_SSL_Security_On_Apache2.html
      SSLOpenSSLConfCmd Curves X25519:secp521r1:secp384r1:prime256v1

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

      # Fixing faulty mime type configuration for xml files.
      AddType application/xml .xml

      # Enable HSTS over HTTPS only
      # @see https://https.cio.gov/hsts/
      # @see https://hstspreload.org/
      Header always set Strict-Transport-Security: "max-age=31536000; includeSubDomains; preload" env=HTTPS

      # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin
      Header set Access-Control-Allow-Origin: *

      # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Expect-CT
      Header set Expect-CT: 'max-age=86400, enforce, report-uri="https://searx.${gnu-domain}/about"'
      
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
      # Do not allows refferer information when protocol is downgraded.
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

      # Accept connections for these vhosts from non-SNI clients
      SSLStrictSNIVHostCheck off

      # Enable SSL stapling.
      SSLUseStapling on

      SSLStaplingCache shmcb:/tmp/stapling_cache(128000)
    '';
  };

}
