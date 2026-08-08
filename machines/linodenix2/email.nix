# linodenix2: mail server configuration for Linode VPS.
# scope: server
#
# Provides mailserver and ACME certificates.

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
    #Using Let's Encrypt instead of self-signed certificate.
    # The Caddy webserver takes care of certificates via ACME.
    # certificateScheme = "acme";
    domains = [
      "${imigrant-domain}"
    ];
    accounts = {
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
}
