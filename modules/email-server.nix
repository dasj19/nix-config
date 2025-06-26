{ config, lib, ... }:
{
  options = {
    mailConfig.fqdn = lib.mkOption {
      type = lib.types.anything;
      default = false;
    };
    mailConfig.domains = lib.mkOption {
      type = lib.types.anything;
      default = false;
    };
    mailConfig.accounts = lib.mkOption {
      type = lib.types.anything;
      default = false;
    };
  };

  config = {
    # Setup for the mailserver.
    mailserver.enable = true;

      # Uses Let's Encrypt instead of self-signed certificate.
      # The apache2 webserver takes care of getting the certificate.
    mailserver.certificateScheme = "acme";

    # Index the body of the mails to perform full text search.
    mailserver.fullTextSearch.enable = true;
    # Index new email as they arrive.
    mailserver.fullTextSearch.autoIndex = true;
    # Tells dovecot to fail any body search query that cannot use an index.
    mailserver.fullTextSearch.enforced = "body";

    # Debug authentication. @see: https://serverfault.com/a/1020853
    # Disabled to allow fail2ban to do its job.
    #services.dovecot2.extraConfig = ''
    #  auth_verbose = yes
    #'';

    # Email server settings.
    mailserver.fqdn = config.mailConfig.fqdn;

    # list of domains in format: [ "domain.tld" ];
    mailserver.domains = config.mailConfig.domains;
    mailserver.loginAccounts = config.mailConfig.accounts;

    mailserver.stateVersion = 3;
    # IMAPS only.
    mailserver.enableImap = false;
    mailserver.enableImapSsl = true;
    # SMTPS only.
    mailserver.enableSubmission = false;
    mailserver.enableSubmissionSsl = true;

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
  };
}
