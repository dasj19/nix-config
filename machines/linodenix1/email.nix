{
  config,
  gitSecrets,
  lib,
  pkgs,
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
  sops.secrets.cloudflare_email = { };
  sops.secrets.cloudflare_dns_api_token = { };
  sops.secrets.cloudflare_zone_api_token = { };

  # Accept Acme EULA.
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "postmaster@${surname-domain}";
  security.acme.defaults.dnsProvider = "cloudflare";
  security.acme.defaults.credentialFiles = {
    "CLOUDFLARE_EMAIL_FILE" = config.sops.secrets.cloudflare_email.path;
    "CF_DNS_API_TOKEN_FILE" = config.sops.secrets.cloudflare_dns_api_token.path;
    "CF_ZONE_API_TOKEN_FILE" = config.sops.secrets.cloudflare_zone_api_token.path;
  };

  mailserver = {
    fqdn = "mail.${surname-domain}";
    x509.useACMEHost = "mail.${surname-domain}";
    # Using Let's Encrypt certificate because self-signed certificates are troublesome.
    #certificateScheme = lib.mkForce "acme-nginx";
    domains = [
      "${surname-domain}"
    ];
    loginAccounts = {
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

  # Add extra configuration for postfix.
  # https://linux-audit.com/postfix-hardening-guide-for-security-and-privacy/
  #services.postfix.extraConfig = ''
  #  # Require the use of HELO command.
  #  smtpd_helo_required=yes
  #  # Apply helo restrictions.
  #  smtpd_helo_restrictions=permit_mynetworks, permit_sasl_authenticated, reject_invalid_helo_hostname, reject_non_fqdn_helo_hostname, reject_unknown_helo_hostname
  #  # Apply recipient restrictions.
  #  #smtpd_recipient_restrictions=permit_mynetworks, permit_sasl_authenticated
  #  # Reject non-existent sender addresses.
  #  smtpd_reject_unlisted_sender=yes
  #  # Enable SASL authentication.
  #  smtpd_sasl_auth_enable=yes
  #  # Enable dns lookups.
  #  smtp_dns_support_level=enabled
  #'';

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
