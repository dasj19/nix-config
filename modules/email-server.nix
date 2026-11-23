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
  mailserver.listeners.imap.enable = false;
  mailserver.listeners.imaps.enable = true;
  # SMTPS only.
  mailserver.listeners.submission.enable = false;
  mailserver.listeners.submissions.enable = true;

  # Local caching, recursive and DNSSEC-validating resolver, required by the
  # mailserver since it dropped `localDnsResolver` (which enabled kresd).
  services.unbound.enable = true;

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
