{ config, pkgs, lib, ... }:

  let
    release = "master";
    # Agenix paths:
    mailserver-account-daniel-password = config.age.secrets.mailserver-account-daniel-password.path;
    mailserver-account-daniel-aliases = config.age.secrets.mailserver-account-daniel-aliases.path;
    # Agenix strings:
    gnu-domain = lib.strings.fileContents config.age.secrets.webserver-virtualhost-gnu-domain.path;    
    mailserver-fqdn = lib.strings.fileContents config.age.secrets.mailserver-fqdn.path;
    mailserver-account-daniel-email = lib.strings.fileContents config.age.secrets.mailserver-account-daniel-email.path;
    
  in {
    imports = [
      (builtins.fetchTarball {
        url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz";
        # This hash needs to be updated
        sha256 = "0h35al73p15z9v8zb6hi5nq987sfl5wp4rm5c8947nlzlnsjl61x";
      })
    ];

    # Agenix secret files.
    age.secrets.mailserver-fqdn.file = secrets/mailserver-fqdn.age;
    age.secrets.mailserver-domains.file = secrets/mailserver-domains.age;
    age.secrets.mailserver-account-daniel-email.file = secrets/mailserver-account-daniel-email.age;
    age.secrets.mailserver-account-daniel-password.file = secrets/mailserver-account-daniel-password.age;
    age.secrets.mailserver-account-daniel-aliases.file = secrets/mailserver-account-daniel-aliases.age;
    age.secrets.webserver-virtualhost-gnu-domain.file = secrets/webserver-virtualhost-gnu-domain.age;

    mailserver = {
      enable = true;

      # Use Let's Encrypt instead of self-signed certificate.
      # Set to manual because apache takes care of the SSL
      # @TODO: make the path dynamic through a variable if possible.
      certificateScheme = 1;
      certificateFile = "/var/lib/acme/.lego/mail.${gnu-domain}/549839e4ae8616de7ad5/mail.${gnu-domain}.crt";
      keyFile = "/var/lib/acme/.lego/mail.${gnu-domain}/549839e4ae8616de7ad5/mail.${gnu-domain}.key";

      fqdn = mailserver-fqdn;
      # list of domains in format: [ "domain.tld" ];
      domains = import config.age.secrets.mailserver-domains.path;
      loginAccounts = {
           # Account name in the form of "username@domain.tld".
           "${mailserver-account-daniel-email}" = {
              # Password can be generated running: 'mkpasswd -sm bcrypt'.
              hashedPasswordFile = mailserver-account-daniel-password;
              # List of aliases in format: [ "username@domain.tld" ].
              aliases = import mailserver-account-daniel-aliases;
          };
      };
      # Index the body of the mails to perform full text search.
      fullTextSearch = {
        enable = true;
        # Index new email as they arrive.
        autoIndex = true;
        # This only applies to plain text attachments, binary attachments are never indexed.
        indexAttachments = true;
        # Tells dovecot to fail any body search query that cannot use an index.
        enforced = "body";
      };
    };

  # Add extended spam information.
  services.rspamd.extraConfig = ''
    milter_headers {
      use = ["x-spamd-bar", "x-spam-level", "x-spam-flag", "x-spam-status", "x-spamd-result", "spam-header", "authentication-results"];
    }
  '';
}
