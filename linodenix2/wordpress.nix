{ config, lib, pkgs, ... }:

let

# Import host-specific variables.
variables = import ./secrets/variables.nix;

patchedWordpress = pkgs.wordpress.overrideAttrs (old: {

  installPhase = old.installPhase + ''
    mkdir -p $out/share/wordpress/wp-content/languages/themes

    # Remove the default wordpress themes (to not get bothered about updates).
    rm -rf $out/share/wordpress/wp-content/themes/twentytwenty
    rm -rf $out/share/wordpress/wp-content/themes/twentytwentyone
    rm -rf $out/share/wordpress/wp-content/themes/twentytwentytwo

    # Remove default not used plugins (to not get bothered about updates).
    rm -rf $out/share/wordpress/wp-content/plugins/akismet
    rm -rf $out/share/wordpress/wp-content/plugins/hello.php

    # Symlink to a module config file.
    # This is still not editable from the wordpress panel but can be changed manually.
    ln -s /var/lib/wordpress/${variables.primaryDomain}/cache/advanced-cache.php $out/share/wordpress/wp-content/advanced-cache.php
    ln -s /var/lib/wordpress/${variables.primaryDomain}/blogstream-currency.json $out/share/wordpress/wp-content/blogstream-currency.json
  '';
    
});

# For shits and giggles, let's package the responsive theme
blogstream = pkgs.stdenv.mkDerivation rec {
  name = "blogstream";
  version = "1.1";
  src = builtins.fetchGit {
    url = "ssh://git@github.com/dasj19/blogstream.git";
    ref = "main";
    rev = "2f5333c19ccbf0e1f50ad2c41470f8cde0e000fe";
  };
  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = ''
    mkdir -p $out; cp -R * $out/
  '';
};

# Pressbook theme.
pressbook = pkgs.stdenv.mkDerivation rec {
  name = "pressbook";
  version = "1.9.4";
  src = pkgs.fetchurl {
    url = "https://downloads.wordpress.org/theme/pressbook.1.9.4.zip";
    sha256 = "0ngy15q2c9hg3i4npp3nz1a01gvv73f0kn96akrrhh46m6ja51ml";
  };
  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = ''
    mkdir -p $out; cp -R * $out/
  '';
};

# Oceanly theme.
oceanly = pkgs.stdenv.mkDerivation rec {
  name = "oceanly";
  version = "1.7.3";
  src = pkgs.fetchurl {
    url = "https://downloads.wordpress.org/theme/oceanly.1.7.3.zip";
    sha256 = "0dj3ljw0551mzlbrxjfyv6hgq0ga4fr5zfpybiil38sf3g8fsdx0";
  };
  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = ''
    mkdir -p $out; cp -R * $out/
  '';
};


# Oceanly News theme.
oceanly-news = pkgs.stdenv.mkDerivation rec {
  name = "oceanly-news";
  version = "1.2.6";
  src = pkgs.fetchurl {
    url = "https://downloads.wordpress.org/theme/oceanly-news.1.2.6.zip";
    sha256 = "0p9z4r2i4h7j8b3vjjc06nyjgzj39bw97d8yiipr2f68883kmy58";
  };
  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = ''
    mkdir -p $out; cp -R * $out/
  '';
};

# Wordpress plugin 'classic-editor'.
classic-editor = pkgs.stdenv.mkDerivation {
  name = "classic-editor";
  # Download the plugin from the wordpress site
  src = pkgs.fetchurl {
    url = "https://downloads.wordpress.org/plugin/classic-editor.1.6.3.zip";
    sha256 = "0ldkxdpffjfja9jrsmygsysmsad2ngkbydkbzj3q4i0yczi625lj";
  };
  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = "mkdir -p $out; cp -R * $out/";
};

# https://downloads.wordpress.org/plugin/easy-wp-meta-description.1.2.6.zip
easy-wp-meta-description = pkgs.stdenv.mkDerivation {
  name = "easy-wp-meta-description";
  # Download the plugin from the wordpress site
  src = pkgs.fetchurl {
    url = "https://downloads.wordpress.org/plugin/easy-wp-meta-description.1.2.6.zip";
    hash = "sha256-k/gQ3ryTuM1YpTO393dL3jOdyrKBNIDdCbOdpaYlAqM=";
  };
  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = "mkdir -p $out; cp -R * $out/";
};


# https://downloads.wordpress.org/plugin/wordpress-gzip-compression.1.0.zip
worpress-gzip-compression = pkgs.stdenv.mkDerivation {
  name = "worpress-gzip-compression";
  # Download the plugin from the wordpress site
  src = pkgs.fetchurl {
    url = "https://downloads.wordpress.org/plugin/wordpress-gzip-compression.1.0.zip";
    sha256 = "156w8a7fi2yrps3kix46djd89x9ic7fjiwqz5hgpm2923v7ffwgn";
  };

  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = "mkdir -p $out; cp -R * $out/";
};

# https://downloads.wordpress.org/plugin/disable-json-api.zip
disable-json-api = pkgs.stdenv.mkDerivation {
  name = "disable-json-api";
  # Download the plugin from the wordpress site
  src = pkgs.fetchurl {
    url = "https://downloads.wordpress.org/plugin/disable-json-api.zip";
    hash = "sha256-BqPhNI9NURpIMcdPyho1DPrt96oNhgdjYt6fiV/90KM=";
  };

  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = "mkdir -p $out; cp -R * $out/";
};

# https://downloads.wordpress.org/plugin/humanstxt.1.3.1.zip
humanstxt = pkgs.stdenv.mkDerivation {
  name = "humanstxt";
  # Download the plugin from the wordpress site
  src = pkgs.fetchurl {
    url = "https://downloads.wordpress.org/plugin/humanstxt.1.3.1.zip";
    sha256 = "1100qmnlxzgydglr7pai1l6ajnsz0xr7vrf3vw2yhx2mzgjjrlj8";
  };
  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = "mkdir -p $out; cp -R * $out/";
};

# https://github.com/dasj19/stop-xml-rpc/releases/download/v0.1/stop-xml-rpc.0.1.zip
stop-xml-rpc = pkgs.stdenv.mkDerivation {
  name = "stop-xml-rpc";
  # Download the plugin from the wordpress site
  src = pkgs.fetchurl {
    url = "https://github.com/dasj19/stop-xml-rpc/releases/download/v0.1/stop-xml-rpc.0.1.zip";
    sha256 = "0iq846b257jjqc2zihs08ywqc4x9fqcv5qlmdldpnx2855vl8hv4";
  };
  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = "mkdir -p $out; cp -R * $out/";
};

# https://downloads.wordpress.org/plugin/advanced-custom-fields.6.2.2.zip
# https://downloads.wordpress.org/plugin/advanced-custom-fields.6.2.5.zip
advanced-custom-fields = pkgs.stdenv.mkDerivation {
  name = "advanced-custom-fields";
  # Download the plugin from the wordpress site
  src = pkgs.fetchurl {
    url = "https://downloads.wordpress.org/plugin/advanced-custom-fields.6.2.5.zip";
    sha256 = "1qwgww1fkix1j8c1sdpr0099h16q5msvpj1k35cg80jsyl0r6bhx";
  };
  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = "mkdir -p $out; cp -R * $out/";
};

# https://downloads.wordpress.org/plugin/tinymce-advanced.5.9.2.zip
tinymce-advanced = pkgs.stdenv.mkDerivation {
  name = "tinymce-advanced";
  # Download the plugin from the wordpress site
  src = pkgs.fetchurl {
    url = "https://downloads.wordpress.org/plugin/tinymce-advanced.5.9.2.zip";
    sha256 = "1iv9zpxmdllqqq28cx1nr425jnv5nf1pnv95s0krq3wxvhsnck7c";
  };
  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = "mkdir -p $out; cp -R * $out/";
};

# https://downloads.wordpress.org/plugin/cluevo-lms.1.11.0.zip
cluevo-lms = pkgs.stdenv.mkDerivation {
  name = "cluevo-lms";
  # Download the plugin from the wordpress site
  src = pkgs.fetchurl {
    url = "https://downloads.wordpress.org/plugin/cluevo-lms.1.11.0.zip";
    hash = "sha256-Enmw4lbBljLOsdUA1D0Psg0Wq3sTioyZR3/fGOu/o7U=";
  };
  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = "mkdir -p $out; cp -R * $out/";
};

wp-pagenavi = pkgs.stdenv.mkDerivation {
  name = "wp-pagenavi";
  # Download the plugin from the wordpress site
  src = pkgs.fetchurl {
    url = "https://downloads.wordpress.org/plugin/wp-pagenavi.2.94.1.zip";
    hash = "sha256-7w5UKrrtadFUHgBM3eqaJc+PHi0nZqmQFPoYj3bAvos=";
  };
  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = "mkdir -p $out; cp -R * $out/";
};

# https://downloads.wordpress.org/plugin/wpforms-lite.1.8.6.2.zip
wpforms-lite = pkgs.stdenv.mkDerivation {
  name = "wpforms-lite";
  # Download the plugin from the wordpress site
  src = pkgs.fetchurl {
    url = "https://downloads.wordpress.org/plugin/wpforms-lite.1.8.6.2.zip";
    sha256 = "0zp6bv2sk0jdv2ady95g2zl6h29g5903p1ls0ra1sva2y418g0xs";
  };
  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = "mkdir -p $out; cp -R * $out/";
};

# https://downloads.wordpress.org/plugin/add-featured-image-to-rss-feed.1.1.2.zip
add-featured-image-to-rss-feed = pkgs.stdenv.mkDerivation {
  name = "add-featured-image-to-rss-feed";
  # Download the plugin from the wordpress site
  src = pkgs.fetchurl {
    url = "https://downloads.wordpress.org/plugin/add-featured-image-to-rss-feed.1.1.2.zip";
    hash = "sha256-vBOt52qhluS0MVQDPd1AqbB9JAFlGhuZcnZ1B7KjYv4=";
  };
  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = "mkdir -p $out; cp -R * $out/";
};

# https://downloads.wordpress.org/plugin/edit-author-slug.1.9.0.zip
edit-author-slug = pkgs.stdenv.mkDerivation {
  name = "edit-author-slug";
  # Download the plugin from the wordpress site
  src = pkgs.fetchurl {
    url = "https://downloads.wordpress.org/plugin/edit-author-slug.1.9.0.zip";
    sha256 = "1dgmk7q98yd03n6vkqa72dcc3by84f55l2plylsdfxj07cpi6rrk";
  };
  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = "mkdir -p $out; cp -R * $out/";
};

# https://downloads.wordpress.org/plugin/redirection.5.4.1.zip
redirection = pkgs.stdenv.mkDerivation {
  name = "redirection";
  # Download the plugin from the wordpress site
  src = pkgs.fetchurl {
    url = "https://downloads.wordpress.org/plugin/redirection.5.4.1.zip";
    sha256 = "14cgymm1xj3m6li4yzryb186wmg5f7ffjc750m2g4d7lmjqfifsl";
  };
  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = "mkdir -p $out; cp -R * $out/";
};

# https://downloads.wordpress.org/plugin/images-to-webp.4.6.zip
images-to-webp = pkgs.stdenv.mkDerivation {
  name = "images-to-webp";
  # Download the plugin from the wordpress site
  src = pkgs.fetchurl {
    url = "https://downloads.wordpress.org/plugin/images-to-webp.4.6.zip";
    sha256 = "1kpqqm3h8jf4ani394wd9ln5xbk7f4pvpbkya0046s4rkn5103m0";
  };
  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = ''
    mkdir -p $out; cp -R * $out/
  '';
};


# https://downloads.wordpress.org/plugin/hyper-cache.3.4.2.zip
hyper-cache = pkgs.stdenv.mkDerivation {
  name = "hyper-cache";
  # Download the plugin from the wordpress site
  src = pkgs.fetchurl {
    url = "https://downloads.wordpress.org/plugin/hyper-cache.3.4.2.zip";
    sha256 = "1vwkfym9r7dy0w0n75pknk6axvd1gk77am0vq2sarn6yf9pd8ik1";
  };
  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = ''
    mkdir -p $out; cp -R * $out/

    # change the cache directory
    #substituteInPlace $out/plugin.php \
    #  --replace "WP_CONTENT_DIR" "'/var/lib/wordpress/${variables.primaryDomain}'"
    #substituteInPlace $out/options.php \
    #  --replace "WP_CONTENT_DIR" "'/var/lib/wordpress/${variables.primaryDomain}'"

  '';
};

# https://downloads.wordpress.org/plugin/very-simple-contact-form.14.9.zip
very-simple-contact-form = pkgs.stdenv.mkDerivation {
  name = "very-simple-contact-form";
  # Download the plugin from the wordpress site
  src = pkgs.fetchurl {
    url = "https://downloads.wordpress.org/plugin/very-simple-contact-form.14.9.zip";
    sha256 = "09h2bgvpx1s54s2v8jci3r2qw0lmmxki0ndj6cxaj1c2ck73832d";
  };
  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = ''
    mkdir -p $out; cp -R * $out/
  '';
};


# https://downloads.wordpress.org/plugin/say-it.4.0.1.zip
say-it = pkgs.stdenv.mkDerivation rec {
  name = "say-it";
  version = "4.0.2";
  src = /etc/nixos/wordpress/say-it.zip;
  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = ''
    mkdir -p $out; cp -R * $out/
  '';
};

# https://downloads.wordpress.org/plugin/mx-time-zone-clocks.4.1.zip  
mx-time-zone-clocks = pkgs.stdenv.mkDerivation rec {
  name = "mx-time-zone-clocks";
  version = "3.9";
  # Download the plugin from the wordpress site
  src = pkgs.fetchurl {
    url = "https://downloads.wordpress.org/plugin/mx-time-zone-clocks.4.1.zip";
    sha256 = "0qni1f1yh4f471039abjgysfnhx2xq0zkz6lsdy92k4p39fhq9lv";
  };
  # We need unzip to build this package
  buildInputs = [ pkgs.unzip ];
  # Installing simply means copying all files to the output directory
  installPhase = ''
    mkdir -p $out; cp -R * $out/
  '';
};

in
{
  # phpfpm with custom extensions.
  services.phpfpm.phpOptions = ''
    extension=${pkgs.php82Extensions.imagick}/lib/php/extensions/imagick.so
  '';
  # Using caddy webserver.
  services.wordpress.webserver = "caddy";
  # Note the .sites - the upstream module says this is the new syntax,
  # the old is only supported because of a hack at the very top of the module
  services.wordpress.sites = {
    "${variables.primaryDomain}" = {
      package = patchedWordpress;
      database.host = "localhost";
      database.name = "${variables.primaryDatabase}";
      database.createLocally = true;

      settings = {
        WP_CACHE = true;
        # hyper-cache options.
        HYPER_CACHE_FOLDER = "/var/lib/wordpress/${variables.primaryDomain}/cache";
      };
    
      themes = {
        inherit blogstream;
      };
      plugins = {
        inherit advanced-custom-fields;
        inherit classic-editor;
        inherit wp-pagenavi;
        # SEO
        inherit edit-author-slug;
        inherit easy-wp-meta-description;
        inherit redirection;
        inherit humanstxt;
        # Miscellaneous.
        inherit add-featured-image-to-rss-feed;
        inherit mx-time-zone-clocks;
        inherit very-simple-contact-form;
        inherit wpforms-lite;
        # Cache performance and compression.
        inherit worpress-gzip-compression;
        inherit hyper-cache;
        inherit images-to-webp;
        inherit disable-json-api;
        inherit stop-xml-rpc;
      };

      # Add romanian language.
      languages = [ pkgs.wordpressPackages.languages.ro_RO ];
      settings = {
        WPLANG = "ro_RO";
      };
    };

    "${variables.secondaryDomain}" = {
      package = patchedWordpress;
      database.host = "localhost";
      database.name = "${variables.secondaryDatabase}";
      database.createLocally = true;
      # Add romanian language.
      languages = [ pkgs.wordpressPackages.languages.ro_RO ];

      themes = {
        inherit pressbook;
        inherit oceanly;
        inherit oceanly-news;
      };

      plugins = {
        inherit say-it;
        inherit classic-editor;
        inherit cluevo-lms;
        inherit tinymce-advanced;
        # SEO.
        inherit humanstxt;
      };

      settings = {
        WPLANG = "ro_RO";
        # https://core.trac.wordpress.org/ticket/48689#comment:13
        FS_METHOD = "direct";
      }; 
    };
  };
  services.caddy = {
    enable = true;
    globalConfig = ''
      servers {
        protocols h1 h2 h3
      }
    '';

    virtualHosts."www.${variables.primaryDomain}" = {
      extraConfig = ''
         # Redirect www to non-ww with https.
         redir https://{labels.1}.{labels.0}{uri} permanent
      '';
    };
    virtualHosts."${variables.primaryDomain}" = {

      extraConfig = ''
        # Rewrite image paths to existent .webp files.
        rewrite @images {path}.webp
        # Definition of supported images.
        @images {
          # Apparently this is more efficitent than regex matching.
          # https://caddyserver.com/docs/caddyfile/matchers#file
          # https://caddy.community/t/correct-way-to-set-expires-on-caddy-2/7914/13
          file
          path *.jpg *.jpeg *.gif *.png
        }
        # Definition of supported assets.
        @assets {
          # Apparently this is more efficitent than regex matching.
          # https://caddyserver.com/docs/caddyfile/matchers#file
          # https://caddy.community/t/correct-way-to-set-expires-on-caddy-2/7914/13
          file
          path *.png *.jpg *.jpeg *.gif *.webp *.ico *.css *.map *.woff *.woff2 *.eot *.svg *.ttf *.js
        }
        # Use compression.
        encode {
          gzip
          # Compress the following MIME-Types.
          match {
            header content-type "application/*" #*/
            header content-type "font/*" #*/
            header content-type "image/*" #*/
            header content-type "text/*" #*/
          }
        }
        # Headers for assets.
        handle @assets {
          # @TODO: find a way to add the expires header as well, might be handy with old systems.
          header cache-control "max-age=86400"
        }
        # Headers for humans.txt (used by homer to detect if server is online.)
        handle /humans.txt {
          # Allow CORS for humans.txt.
          header access-control-allow-origin "*"
          header access-control-allow-methods "HEAD"
        }
        # Headers for /wp-admin/ paths.
        handle /wp-admin/* { #*/
          # Relax CSP for admin paths.
          # @TODO: Slowly enable more and more CSP attributes: https://content-security-policy.com/
          header content-security-policy "upgrade-insecure-requests"
        }
        # Headers for all other paths.
        handle {
          # Keep header names lowercased. They should be compared in a case-insensitive fashion.
          header {
            # Enable HSTS over HTTPS only
            # @see https://https.cio.gov/hsts/
            # @see https://hstspreload.org/
            strict-transport-security: "max-age=31536000; includeSubDomains; preload" env=HTTPS

            # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Content-Type-Options
            # Prevent MIME type sniffing attacks.
            x-content-type-options "nosniff"

            # https://infosec.mozilla.org/guidelines/web_security#x-frame-options
            # Prevent website from framing this site.
            x-frame-options: "DENY"

            # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-XSS-Protection
            # Prevent XSS in older browsers that don't support CSP.
            x-xss-protection "1; mode=block"

            # https://infosec.mozilla.org/guidelines/web_security#content-security-policy
            # https://content-security-policy.com/
            # TODO: add an endpoint for: report-uri https://a.report.domain/about https://a.report.domain;
            content-security-policy: "default-src https: ; frame-ancestors 'none'; script-src https: 'unsafe-inline' ; connect-src https: ; img-src * data: ; style-src https: ; base-uri 'self'; form-action 'self'; font-src https: ; object-src 'none' ;"

            # Replace the PHP signature from the existing headers, and don't set new headers where there aren't any.
            x-powered-by ".*" "PHP"
            # Delay assigning headers until everything is ready, essentially making this block authoritative.
            defer
          }
        }
      '';
    };
    virtualHosts."${variables.secondaryDomain}" = {
      extraConfig = ''
        # Headers for humans.txt (used by homer to detect if server is online.)
        handle /humans.txt {
          # Allow CORS for humans.txt.
          header access-control-allow-origin "*"
          header access-control-allow-methods "HEAD"
        }
      '';
    };
  };
}
