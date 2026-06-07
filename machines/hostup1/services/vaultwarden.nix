{
  config,
  gitSecrets,
  ...
}:

let
  foss-domain = gitSecrets.fossDomain;
in

{
  services.vaultwarden.enable = true;
  # to avoid having ADMIN_TOKEN in the nix store
  # it can be set with the help of an environment file
  # this file must be created by hand
  # generate ADMIN_TOKEN with `vaultwarden hash`
  services.vaultwarden.environmentFile = "/var/lib/vaultwarden/vaultwarden.env";
  services.vaultwarden.config = {
    # Refer to https://github.com/dani-garcia/vaultwarden/blob/main/.env.template
    DOMAIN = "https://vaultwarden.${foss-domain}";
    SIGNUPS_ALLOWED = false;

    ROCKET_ADDRESS = "127.0.0.1";
    ROCKET_PORT = 8222;
    ROCKET_LOG = "critical";

    # When using an external mail server, follow:
    #   https://github.com/dani-garcia/vaultwarden/wiki/SMTP-configuration
    # SMTP_HOST = "127.0.0.1";
    # SMTP_PORT = 25;
    # SMTP_SECURITY = off;

    # SMTP_FROM = "admin@bitwarden.example.com";
    # SMTP_FROM_NAME = "example.com Bitwarden server";
  };

  services.vaultwarden.configurePostgres = true;
  services.vaultwarden.dbBackend = "postgresql";

  # Serve Rocket through caddy proxy.
  services.caddy.virtualHosts."vaultwarden.${foss-domain}".extraConfig = ''
    encode zstd gzip

    reverse_proxy localhost:8222 {
        header_up X-Real-IP {remote_host}
    }
  '';

}
