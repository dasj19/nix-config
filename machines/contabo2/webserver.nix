{ config, lib, pkgs, ... }:

let
  variables = import ./secrets/variables.nix;
in

{
  # Using caddy webserver.
  services.caddy.enable = true;
  services.caddy.virtualHosts."www.${variables.firmDomain}".extraConfig = ''
    respond "Hello, world!"
  '';
}