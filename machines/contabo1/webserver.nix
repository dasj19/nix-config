{ gitSecrets, ... }:

let
  # Host-related variables.
  fritweb-domain = gitSecrets.fritwebDomain;
in
{
  services.caddy = {
    enable = true;
    globalConfig = ''
      servers {
        protocols h1 h2 h3
      }
    '';

    virtualHosts."www.${fritweb-domain}" = {
      extraConfig = ''
        # Redirect www to non-ww with https.
        redir https://{labels.1}.{labels.0}{uri} permanent
      '';
    };
    virtualHosts."${fritweb-domain}" = {
      extraConfig = ''
        # Generic message.
        respond "Hejsa, vi er i gang med at bygge noget nyt her!"
      '';
    };
  };
}

