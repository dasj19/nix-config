{ fetchurl, ... }:

{
  pname = "caddy-browse";
  version = "0.1";
  src = fetchurl {
    url = "https://github.com/caddyserver/caddy/raw/refs/heads/master/modules/caddyhttp/fileserver/browse.html";
    hash = "";
  };

  installPhase = ''
    cp browse.html /var/lib/caddy
  '';

}
