{ config, gitSecrets, pkgs, lib, ... }:

let
     fritweb-domain = gitSecrets.fritwebDomain;
in

{

    # Fetch the email server.
    imports = [
      ./../../modules/email-server.nix
    ];

    sops.secrets.daniel_fritweb_email_password = {};

    # Setup for the mailserver.
    mailserver = {
      fqdn = "mail.${fritweb-domain}";
      # list of domains in format: [ "domain.tld" ];
      domains = [
        "${fritweb-domain}"
      ]; #import config.age.secrets.mailserver-domains.path;
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

 # mailserver.stateVersion = 3;

  # Debug authentication. @see: https://serverfault.com/a/1020853
  # Disabled to allow fail2ban to do its job.
  #services.dovecot2.extraConfig = ''
  #  auth_verbose = yes
  #'';

#  # Enable required extensions.
#  services.dovecot2.sieve.extensions = [
#    # To file spam into spam folder.
#    "fileinto"
#  ];


  # Add extended spam information.
#  services.rspamd.extraConfig = ''
#    milter_headers {
#      use = ["x-spamd-bar", "x-spam-level", "x-spam-flag", "x-spam-status", "x-spamd-result", "spam-header", "authentication-results"];
#    }
#    actions {
#      greylist = 6; # Apply greylisting when reaching this score
#    }
#  '';
}
