{ config, gitSecrets, ... }:

let
  release = "master";
  daniel-domain = gitSecrets.danielPrimaryDomain;
  daniel-email = gitSecrets.danielHackerEmail;
  daniel-fqdn = gitSecrets.danielMailserverFqdn;

in

{
    imports = [
      (builtins.fetchTarball {
        url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz";
        # This hash needs to be updated
        sha256 = "1flgj5hqzr76x2ff339kzbrfwilwy81wmml69nnwr2l5apmmly8j";
      })
    ];

    mailserver = {
      enable = true;
      fqdn = daniel-fqdn;
      # Use Let's Encrypt instead of self-signed certificate.
      # The Caddy webserver takes care of certificates via ACME.
      certificateScheme = "acme";
      domains = [
        "${daniel-domain}"
      ];
      loginAccounts = {
        "${daniel-email}" = {
              # For generating new hashed passwords use the following commands.
              # nix shell -p apacheHttpd
              # htpasswd -nbB "" "super secret password" | cut -d: -f2 > /hashed/password/file/location
              hashedPasswordFile = config.age.secrets.mailserver-account-daniel-password.path;

              # List of email aliases: "username@domain.tld" .
              aliases = [ "postmaster@${daniel-domain}" "webmaster@${daniel-domain}" ];
              # Catch all emails from the primary domain.
              catchAll = [ daniel-domain ];
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

