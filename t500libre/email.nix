{ config, pkgs, lib, gitSecrets, ... }:

  let
    # NixOS Simple Mail Server release branch.
    release = "master";

    # Git secrets.
    gitSecrets = builtins.fromJSON(builtins.readFile ./secrets/git-secrets.json);
    mailserver-fqdn = gitSecrets.mailserverFqdn;
    mailserver-daniel-email = gitSecrets.mailserverDanielEmail;
    gnu-domain = gitSecrets.gnuDomain;

  in {
    # Fetch the email server.
    imports = [
      (builtins.fetchTarball {
        url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz";
        # This hash needs to be updated
        sha256 = "1j0r52ij5pw8b8wc5xz1bmm5idwkmsnwpla6smz8gypcjls860ma";
      })
    ];

    # Sops secrets.
    sops.secrets.daniel_email_password = {};

    # Setup for the mailserver.
    mailserver = {
      enable = true;

      # Uses Let's Encrypt instead of self-signed certificate.
      # The apache2 webserver takes care of getting the certificate.
      certificateScheme = "acme";

      fqdn = mailserver-fqdn;
      # list of domains in format: [ "domain.tld" ];
      domains = [ gnu-domain ];
      loginAccounts = {
           # Account name in the form of "username@domain.tld".
           "${mailserver-daniel-email}" = {
              # Password can be generated running: 'mkpasswd -sm bcrypt'.
              hashedPasswordFile = config.sops.secrets.daniel_email_password.path;
              # List of aliases in format: [ "username@domain.tld" ].
              aliases = [
                "postmaster@${gnu-domain}"
                "tor@${gnu-domain}"
                "webmaster@${gnu-domain}"
              ];
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

  # Debug authentication. @see: https://serverfault.com/a/1020853
  # Disabled to allow fail2ban to do its job.
  #services.dovecot2.extraConfig = ''
  #  auth_verbose = yes
  #'';

  # Enable required extensions.
  services.dovecot2.sieve.extensions = [
    # To file spam into spam folder.
    "fileinto"
  ];

  # Add extended spam information.
  services.rspamd.extraConfig = ''
    milter_headers {
      use = ["x-spamd-bar", "x-spam-level", "x-spam-flag", "x-spam-status", "x-spamd-result", "spam-header", "authentication-results"];
    }
    actions {
      greylist = 6; # Apply greylisting when reaching this score
    }
  '';
}
