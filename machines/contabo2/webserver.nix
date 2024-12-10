{ config, gitSecrets, lib, pkgs, ... }:

let
  firm-domain = gitSecrets.firmDomain;
in

{
  # Using caddy webserver.
  services.caddy.enable = true;
  services.caddy.virtualHosts."www.${firm-domain}".extraConfig = ''
    respond "Hello, world!"
  '';
}