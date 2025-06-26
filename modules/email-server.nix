{
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
