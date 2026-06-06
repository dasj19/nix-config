{
  gitSecrets,
  ...
}:

let
  foss-domain = gitSecrets.fossDomain;
in

{
  services.caddy.enable = true;
  services.caddy.virtualHosts."${foss-domain}".extraConfig = ''
    respond "I'm ready!"
  '';

  networking.firewall.allowedTCPPorts = [
    80   # HTTP  (h1,h2)
    443  # HTTPS (h1,h2)
  ];
  networking.firewall.allowedUDPPorts = [
    443  # HTTPS (h3)
  ];
}
