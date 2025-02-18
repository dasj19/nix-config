{ config, gitSecrets, lib, pkgs, ... }:

let
  release = "master";

#  gitSecrets = builtins.fromJSON(builtins.readFile /etc/nixos/secrets/git-secrets.json);

  daniel-imigrant-email = gitSecrets.danielImigrantEmail;
  imigrant-domain = gitSecrets.imigrantDomain;
  imigrant-fqdn = gitSecrets.imigrantMailserverFqdn;
in

{
#    imports = [
#      (builtins.fetchTarball {
#        url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz";
#        # This hash needs to be updated
#        sha256 = "1h79jqxbaj03n6fcn7dvdry5apykqvw40xlrg9jwbwjl5ykn2qhj";
#      })
#    ];

    sops.secrets.daniel_imigrant_email_password = {};

    mailserver = {
      enable = true;
      fqdn =  imigrant-fqdn;
      # Use Let's Encrypt instead of self-signed certificate.
      # The Caddy webserver takes care of certificates via ACME.
      certificateScheme = "acme";
      domains = [
        "${imigrant-domain}"
      ];
      loginAccounts = {
        "${daniel-imigrant-email}" = {
          # For generating new hashed passwords use the following commands.
          # nix shell -p apacheHttpd
          # htpasswd -nbB "" "super secret password" | cut -d: -f2 > /hashed/password/file/location
          hashedPasswordFile = config.sops.secrets.daniel_imigrant_email_password.path;

          # List of email aliases: "username@domain.tld" .
          aliases = [ "postmaster@${imigrant-domain}" "webmaster@${imigrant-domain}"  ];
        };
      };
      # Index the body of the mails to perform full text search.
      fullTextSearch = {
        enable = true;
        # Index new email as they arrive.
        autoIndex = true;
        # Tells dovecot to fail any body search query that cannot use an index.
        enforced = "body";
      };
    };

  # Enable required extensions.
  services.dovecot2.sieve.extensions = [
    # To file spam into spam folder.
    "fileinto"
  ];

  services.rspamd.extraConfig = ''
    # Add extended spam information.
    milter_headers {
      use = ["x-spamd-bar", "x-spam-level", "x-spam-flag", "x-spam-status", "x-spamd-result", "spam-header", "authentication-results"];
    }
    actions {
      # Apply greylisting when reaching this score
      greylist = 6;
    }
  '';
  }

