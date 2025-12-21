{ config, gitSecrets, ... }:

let
  daniel-imigrant-email = gitSecrets.danielImigrantEmail;
  imigrant-domain = gitSecrets.imigrantDomain;
  imigrant-fqdn = gitSecrets.imigrantMailserverFqdn;
in

{
  # Fetch the email server.
  imports = [
    ./../../modules/email-server.nix
  ];

  sops.secrets.daniel_imigrant_email_password = { };

  mailserver = {
    enable = true;
    fqdn = imigrant-fqdn;
    x509.useACMEHost = imigrant-fqdn;
    # Use Let's Encrypt instead of self-signed certificate.
    # The Caddy webserver takes care of certificates via ACME.
    # certificateScheme = "acme";
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
        aliases = [
          "postmaster@${imigrant-domain}"
          "webmaster@${imigrant-domain}"
        ];
      };
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
