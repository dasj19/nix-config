{ config, pkgs, gitSecrets, ... }:

let
  kanboard = pkgs.callPackage ./kanboard-pkg.nix { };

  # Git secrets.
  gnu-domain = gitSecrets.gnuDomain;

in

{

  # php settings for kanboard,
  services.phpfpm.pools.kanboard = {
    user = "kanboard";
    group = "kanboard";
    settings = {
      "listen.group" = "nginx";
      "pm" = "static";
      "pm.max_children" = 4;
    };
  };

  # kanboard user.
  users.users.kanboard.isSystemUser = true;
  users.users.kanboard.group = "kanboard";
  users.groups.kanboard.members = ["kanboard" "nginx" ];

  # database for kanboard.
  services.postgresql.enable = true;

  # webserver with virtual hosts. @todo: migrate to caddy.
  services.nginx = {
    enable = true;
    virtualHosts."kanboard.${gnu-domain}" = {
      root = pkgs.buildEnv {
        name = "kanboard-configured";
        paths = [
          (pkgs.runCommand "kanboard-over" {meta.priority = 0;} ''
            mkdir -p $out
            for f in index.php jsonrpc.php ; do
              echo "<?php require('$out/config.php');" > $out/$f
              tail -n+2 "${kanboard}/share/kanboard/$f" \
                | sed 's^__DIR__^"${kanboard}/share/kanboard"^' >> $out/$f
            done
            ln -s /var/lib/kanboard $out/data
            ln -s /var/www/kanboard/kanboard-config.php $out/config.php
          '')
          { outPath = "${kanboard}/share/kanboard"; meta.priority = 10; }
        ];
      };
      listen = [        {
          addr = "0.0.0.0";
          port = 8001;
        }
      ];
      locations = {
        "/".index = "index.php";
        "~ \\.php$" = {
          tryFiles = "$uri =404";
          extraConfig = ''
            fastcgi_pass unix:${config.services.phpfpm.pools.kanboard.socket};
          '';
        };
      };
    };
  };
}
