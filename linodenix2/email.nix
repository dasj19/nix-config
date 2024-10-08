{ config, lib, pkgs, ... }:

let
  release = "master";
  variables = import ./secrets/variables.nix;
in

{
    imports = [
      (builtins.fetchTarball {
        url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz";
        # This hash needs to be updated
        sha256 = "1a2d5j56y6vcdnqckjlk5qq8sb6n4flshich82p9x5p9fzrcx2ns";
      })
    ];

    mailserver = {
      enable = true;
      fqdn =  variables.fqdn;
      # Use Let's Encrypt instead of self-signed certificate.
      # The Caddy webserver takes care of certificates via ACME.
      certificateScheme = "acme";
      domains = [
        "${variables.primaryDomain}"
      ];
      loginAccounts = {
        "${variables.danielEmail}" = {
          # For generating new hashed passwords use the following commands.
          # nix shell -p apacheHttpd
          # htpasswd -nbB "" "super secret password" | cut -d: -f2 > /hashed/password/file/location
          hashedPasswordFile = config.age.secrets.mailserver-account-daniel-password.path;

          # List of email aliases: "username@domain.tld" .
          aliases = [ variables.postmasterEmail variables.webmasterEmail ];
        };
      };
      # Index the body of the mails to perform full text search.
      fullTextSearch = {
        enable = true;
        # Index new email as they arrive.
        autoIndex = true;
        # This only applies to plain text attachments, binary attachments are never indexed.
        indexAttachments = true;
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

