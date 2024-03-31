{ config, pkgs, lib, ... }:

  let
    # NixOS Simple Mail Server release branch.
    release = "master";
    # Agenix paths:
    mailserver-account-daniel-password = config.age.secrets.mailserver-account-daniel-password.path;
    mailserver-account-daniel-aliases = config.age.secrets.mailserver-account-daniel-aliases.path;
    # Agenix strings:
    gnu-domain = lib.strings.fileContents config.age.secrets.webserver-virtualhost-gnu-domain.path;    
    mailserver-fqdn = lib.strings.fileContents config.age.secrets.mailserver-fqdn.path;
    mailserver-account-daniel-email = lib.strings.fileContents config.age.secrets.mailserver-account-daniel-email.path;
    
  in {
    # Fetch the email server.
    imports = [
      (builtins.fetchTarball {
        url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz";
        # This hash needs to be updated
        sha256 = "1a2d5j56y6vcdnqckjlk5qq8sb6n4flshich82p9x5p9fzrcx2ns";
      })
    ];

    # Agenix secret files.
    age.secrets.mailserver-fqdn.file = secrets/mailserver-fqdn.age;
    age.secrets.mailserver-domains.file = secrets/mailserver-domains.age;
    age.secrets.mailserver-account-daniel-email.file = secrets/mailserver-account-daniel-email.age;
    age.secrets.mailserver-account-daniel-password.file = secrets/mailserver-account-daniel-password.age;
    age.secrets.mailserver-account-daniel-aliases.file = secrets/mailserver-account-daniel-aliases.age;
    age.secrets.webserver-virtualhost-gnu-domain.file = secrets/webserver-virtualhost-gnu-domain.age;

    # Setup for the mailserver.
    mailserver = {
      enable = true;

      # Uses Let's Encrypt instead of self-signed certificate.
      # The apache2 webserver takes care of getting the certificate.
      certificateScheme = "acme";

      fqdn = mailserver-fqdn;
      # list of domains in format: [ "domain.tld" ];
      domains = import config.age.secrets.mailserver-domains.path;
      loginAccounts = {
           # Account name in the form of "username@domain.tld".
           "${mailserver-account-daniel-email}" = {
              # Password can be generated running: 'mkpasswd -sm bcrypt'.
              hashedPasswordFile = mailserver-account-daniel-password;
              # List of aliases in format: [ "username@domain.tld" ].
              aliases = import mailserver-account-daniel-aliases;
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
