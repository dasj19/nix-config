{
  gitSecrets,
  ...
}:

let
  foss-domain = gitSecrets.fossDomain;
in

{
  services.uptime-kuma.enable = true;


  # Serve dex through caddy proxy.
  services.caddy.virtualHosts."uptime-kuma.${foss-domain}".extraConfig = ''
    reverse_proxy localhost:3001
  '';
}
