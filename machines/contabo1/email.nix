{
  config,
  gitSecrets,
  pkgs,
  lib,
  ...
}:

let
  fritweb-domain = gitSecrets.fritwebDomain;
in

{
  # Fetch the email server.
  imports = [
    ./../../modules/email-server.nix
  ];

  sops.secrets.daniel_fritweb_email_password = { };

  # Setup for the mailserver.
  mailserver = {
    fqdn = "mail.${fritweb-domain}";
    x509.useACMEHost = "mail.${fritweb-domain}";
    # list of domains in format: [ "domain.tld" ];
    domains = [
      "${fritweb-domain}"
    ]; # import config.age.secrets.mailserver-domains.path;
    loginAccounts = {
      # Account name in the form of "username@domain.tld".
      "daniel@${fritweb-domain}" = {
        name = "${fritweb-domain}";
        # Password can be generated running: 'mkpasswd -sm bcrypt'.
        hashedPasswordFile = config.sops.secrets.daniel_fritweb_email_password.path;
        # List of aliases in format: [ "username@domain.tld" ].
        aliases = [
          "postmaster@${fritweb-domain}"
          "webmaster@${fritweb-domain}"
        ];
      };
    };
  };
}
