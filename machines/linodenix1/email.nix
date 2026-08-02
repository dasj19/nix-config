{
  config,
  gitSecrets,
  ...
}:

let
  surname-domain = gitSecrets.surnameDomain;
in

{
  # Initialize sops secret variables.
  sops.secrets.daniel_surname_email_password = { };
  sops.secrets.gabriel_surname_email_password = { };
  sops.secrets.elena_surname_email_password = { };
  sops.secrets.ioan_surname_email_password = { };
  sops.secrets.test_surname_email_password = { };

  # ACME settings.
  security.acme.defaults.email = "postmaster@${surname-domain}";

  # Email server.
  mailserver = {
    fqdn = "mail.${surname-domain}";
    x509.useACMEHost = "mail.${surname-domain}";
    #Using Let's Encrypt certificate because self-signed certificates are troublesome.
    #certificateScheme = lib.mkForce "acme-nginx";
    domains = [
      "${surname-domain}"
    ];
    accounts = {
      "daniel@${surname-domain}" = {
        # nix-shell -p apacheHttpd
        # htpasswd -nbB "" "super secret password" | cut -d: -f2 > /hashed/password/file/location
        hashedPasswordFile = config.sops.secrets.daniel_surname_email_password.path;

        aliases = [
          "customer@${surname-domain}"
          "postmaster@${surname-domain}"
          "webmaster@${surname-domain}"
        ];
      };
      "gabriel@${surname-domain}" = {
        hashedPasswordFile = config.sops.secrets.gabriel_surname_email_password.path;
      };

      "elena@${surname-domain}" = {
        hashedPasswordFile = config.sops.secrets.elena_surname_email_password.path;
      };
      "ioan@${surname-domain}" = {
        hashedPasswordFile = config.sops.secrets.ioan_surname_email_password.path;
      };
      "testtest@${surname-domain}" = {
        hashedPasswordFile = config.sops.secrets.test_surname_email_password.path;
      };
    };

    #monitoring.alertAddress = "postmaster@${surname-domain}";
    #monitoring.enable = true;
    #monitoring.config = (builtins.readFile /etc/nixos/monitrc);
  };
}
