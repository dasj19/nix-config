{ config, gitSecrets, lib, pkgs, ... }:

let
  firm-domain = gitSecrets.firmDomain;
in

{

  # Using caddy webserver.
  services.caddy.enable = true;
  services.caddy.virtualHosts."www.${firm-domain}".extraConfig = ''
    redir https://${firm-domain}{uri} permanent
  '';
  services.caddy.virtualHosts."${firm-domain}".extraConfig = ''
    respond "Hello, world!"
  '';

  security.acme.certs."${firm-domain}" = {
      group = config.services.caddy.group;

      domain = "${firm-domain}";
      extraDomainNames = [ "www.${firm-domain}" ];
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
  };
}
