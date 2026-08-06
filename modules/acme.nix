# acme: common ACME/Let's Encrypt configuration with Cloudflare DNS.
# scope: servers
#
# Provides shared sops secret declarations and ACME defaults for Cloudflare DNS.
# Individual machines should set security.acme.defaults.email to their ACME contact email.

{ config, ... }:

{
  # SOPS secrets used by the Cloudflare ACME DNS challenge.
  sops.secrets.cloudflare_email = { };
  sops.secrets.cloudflare_dns_api_token = { };
  sops.secrets.cloudflare_zone_api_token = { };

  # ACME defaults with Cloudflare DNS.
  security.acme.acceptTerms = true;
  security.acme.defaults.dnsProvider = "cloudflare";
  security.acme.defaults.credentialFiles = {
    "CLOUDFLARE_EMAIL_FILE" = config.sops.secrets.cloudflare_email.path;
    "CF_DNS_API_TOKEN_FILE" = config.sops.secrets.cloudflare_dns_api_token.path;
    "CF_ZONE_API_TOKEN_FILE" = config.sops.secrets.cloudflare_zone_api_token.path;
  };
}
