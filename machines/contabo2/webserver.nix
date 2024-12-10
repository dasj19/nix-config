{ config, lib, pkgs, ... }:
{
  # Using caddy webserver.
  services.caddy.enable = true;
  services.caddy.virtualHosts."www.${variables.firmDomain}".extraConfig = ''
    respond "Hello, world!"
  '';
}