{
  gitSecrets,
  pkgs,
  ...
}:

let
  daneza-database = gitSecrets.danezaDatabase;
  daneza-domain = gitSecrets.danezaDomain;

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
    '';

  });

  # Pressbook theme.
  pressbook = pkgs.stdenv.mkDerivation rec {
    name = "pressbook";
    version = "2.1.6";
    src = pkgs.fetchurl {
      url = "https://downloads.wordpress.org/theme/pressbook.2.1.6.zip";
      # cspell:disable-next-line
      sha256 = "0gd9g18g8nnqr4hm5r047x6s4m7djb634l924i4s2rhjqrx1ln44";
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
    version = "1.8.3";
    src = pkgs.fetchurl {
      url = "https://downloads.wordpress.org/theme/oceanly.1.8.3.zip";
      # cspell:disable-next-line
      sha256 = "1avcii8ykjjh5vk165fqn2panymcpmy64gc8i99kmi9jd09wy4w2";
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
    version = "1.3.1";
    src = pkgs.fetchurl {
      url = "https://downloads.wordpress.org/theme/oceanly-news.1.3.1.zip";
      # cspell:disable-next-line
      sha256 = "0jphcqrfxqzzx67gq6hkxasq7r8jz3538v1vl6k0avvmmw5xivx8";
    };
    # We need unzip to build this package
    buildInputs = [ pkgs.unzip ];
    # Installing simply means copying all files to the output directory
    installPhase = ''
      mkdir -p $out; cp -R * $out/
    '';
  };

  # Wordpress plugin 'classic-editor'.
  # https://downloads.wordpress.org/plugin/classic-editor.1.6.7.zip
  classic-editor = pkgs.stdenv.mkDerivation {
    name = "classic-editor";
    # Download the plugin from the wordpress site
    src = pkgs.fetchurl {
      url = "https://downloads.wordpress.org/plugin/classic-editor.1.6.7.zip";
      # cspell:disable-next-line
      sha256 = "0rffbss1h92sp66mpcrm6km3s0lils92c8ihhzzjgxk1kjqlaasb";
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
      # cspell:disable-next-line
      sha256 = "1100qmnlxzgydglr7pai1l6ajnsz0xr7vrf3vw2yhx2mzgjjrlj8";
    };
    # We need unzip to build this package
    buildInputs = [ pkgs.unzip ];
    # Installing simply means copying all files to the output directory
    installPhase = "mkdir -p $out; cp -R * $out/";
  };

  # https://downloads.wordpress.org/plugin/tinymce-advanced.5.9.2.zip
  tinymce-advanced = pkgs.stdenv.mkDerivation {
    name = "tinymce-advanced"; # cspell:disable-next-line
    # Download the plugin from the wordpress site
    src = pkgs.fetchurl {
      url = "https://downloads.wordpress.org/plugin/tinymce-advanced.5.9.2.zip";
      # cspell:disable-next-line
      sha256 = "1iv9zpxmdllqqq28cx1nr425jnv5nf1pnv95s0krq3wxvhsnck7c";
    };
    # We need unzip to build this package
    buildInputs = [ pkgs.unzip ];
    # Installing simply means copying all files to the output directory
    installPhase = "mkdir -p $out; cp -R * $out/";
  };

  # https://downloads.wordpress.org/plugin/say-it.4.0.1.zip
  #say-it = pkgs.stdenv.mkDerivation rec {
  #  name = "say-it";
  #  version = "4.0.2";
  #  src = /etc/nixos/wordpress/say-it.zip;
  #  # We need unzip to build this package
  #  buildInputs = [ pkgs.unzip ];
  #  # Installing simply means copying all files to the output directory
  #  installPhase = ''
  #    mkdir -p $out; cp -R * $out/
  #  '';
  #};

  # Say-it with updated composer dependencies.
  say-it = pkgs.stdenv.mkDerivation rec {
    name = "say-it";
    version = "4.0.2";
    src = pkgs.fetchurl {
      url = "https://github.com/dasj19/say-it/releases/download/init/init.zip";
      # cspell:disable-next-line
      sha256 = "18xhw3lkvgaw10bwm1j5jsaa3y8rcyriswsz9jxr4cpi8r27l4nc";
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
  # php-fpm with custom extensions.
  services.phpfpm.phpOptions = ''
    extension=${pkgs.php82Extensions.imagick}/lib/php/extensions/imagick.so
  '';
  # Using caddy webserver.
  services.wordpress.webserver = "caddy";
  # Note the .sites - the upstream module says this is the new syntax,
  # the old is only supported because of a hack at the very top of the module
  services.wordpress.sites = {
    "${daneza-domain}" = {
      package = patchedWordpress;
      database.host = "localhost";
      database.name = "${daneza-database}";
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

    virtualHosts."${daneza-domain}" = {
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
