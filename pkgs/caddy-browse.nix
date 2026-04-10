{ fetchurl, stdenv, ... }:

stdenv.mkDerivation {
  pname = "caddy-browse";
  version = "0.1";
  src = fetchurl {
    url = "https://github.com/caddyserver/caddy/raw/refs/heads/master/modules/caddyhttp/fileserver/browse.html";
    hash = "sha256-ravNuZKICbN9pHKobGTpP7FQUOvLRqTXZJXS38h5bYY=";
  };

  unpackPhase = ''
    echo "No real unpacking as the source is a file"
    cp $src $PWD/browse.html
  '';

  buildPhase = ''
    mkdir -p $out/lib/caddy

    sed -z 's|<footer\b[^>]*>.*</footer>||g' browse.html > $out/lib/caddy/browse.html
  '';

  installPhase = ''true'';

}
