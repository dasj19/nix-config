# email-server: common mailserver configuration.
# scope: servers with mail server
#
# Provides base mailserver settings, full-text search, and rspamd spam filtering.

_:

{
  # Setup for the mailserver.
  mailserver.enable = true;

  # Index the body of the mails to perform full text search.
  mailserver.fullTextSearch.enable = true;
  # Index new email as they arrive.
  mailserver.fullTextSearch.autoIndex = true;

  mailserver.stateVersion = 3;
  # IMAPS only.
  mailserver.enableImap = false;
  mailserver.enableImapSsl = true;
  # SMTPS only.
  mailserver.enableSubmission = false;
  mailserver.enableSubmissionSsl = true;

  # Add extended spam information to rspamd.
  services.rspamd.extraConfig = ''
    milter_headers {
      use = ["x-spamd-bar", "x-spam-level", "x-spam-flag", "x-spam-status", "x-spamd-result", "spam-header", "authentication-results"];
    }
    actions {
      greylist = 6; # Apply greylisting when reaching this score
    }
  '';
}
