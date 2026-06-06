{
  config,
  gitSecrets,
  pkgs,
  lib,
  ...
}:

let
  foss-domain = gitSecrets.fossDomain;
in

{

  # Allow following non-free software.
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "outline"
  ];

  services.outline.enable = true;
  services.outline.publicUrl = "https://outline.${foss-domain}";
  services.outline.port = 3000;
  services.outline.forceHttps = false;
  services.outline.storage.storageType = "local";
  services.outline.oidcAuthentication = {
    authUrl = "https://dex.${foss-domain}/auth";
    tokenUrl = "https://dex.${foss-domain}/token";
    userinfoUrl = "https://dex.${foss-domain}/userinfo";
    clientId = (builtins.elemAt config.services.dex.settings.staticClients 0).id;
    clientSecretFile = (builtins.elemAt config.services.dex.settings.staticClients 0).secretFile;
    scopes = [ "openid" "email" "profile" ];
    usernameClaim = "preferred_username";
    displayName = "Dex";
  };

  # Dex handles logins and user identities.
  # OpenID Connect and OAuth2 identities.
  services.dex.enable = true;
  services.dex.settings = {
    issuer = "https://dex.${foss-domain}";
    storage.type = "postgres";
    storage.config.host = "/run/postgresql";
    web.http = "localhost:5556";
    enablePasswordDB = true;
    staticClients = [
      {
        id = "outline";
        name = "Outline Client";
        redirectURIs = [ "https://outline.${foss-domain}/auth/oidc.callback" ];
        secretFile = "/var/lib/outline/secret_key";
      }
    ];
    staticPasswords = [
      {
        email = "outline-admin@${foss-domain}";
        # bcrypt hash of the string "outline-admin":
        # $(echo outline-admin | htpasswd -BinC 10 admin | cut -d: -f2)
        hash = "$2y$10$qDw9RbMfg50IGMqG3lZ7Keddqr7wQcPNG0GzauaqdJ0uG/4qpRMrG";
        username = "outline-admin";
        # Generated with `$ uuidgen`.
        userID = "34877148-ad2a-44ce-b053-b8861876e9ac";
      }
      {
        email = "outline-user@${foss-domain}";
        # bcrypt hash of the string "outline-user":
        # $(echo outline-user | htpasswd -BinC 10 user | cut -d: -f2)
        hash = "$2y$10$XuGKdZzsLCAFp8fdAK5ZqOkgy5X2LgA5dYg0A1VPwjqPmI1CteAzG";
        username = "outline-user";
        # Generated with `$ uuidgen`.
        userID = "0ff524e8-c0a7-40d5-bb3e-f0953c21a699";
      }
    ];
  };

  # PostgreSQL db used by both dex and outline.
  services.postgresql.enable = true;
  services.postgresql.authentication = pkgs.lib.mkOverride 10 ''
    #type database  DBuser  auth-method
    local all       all     trust
  '';

  # Serve outline through caddy proxy.
  services.caddy.virtualHosts."outline.${foss-domain}".extraConfig = ''
    reverse_proxy localhost:3000
  '';

  # Serve dex through caddy proxy.
  services.caddy.virtualHosts."dex.${foss-domain}".extraConfig = ''
    reverse_proxy localhost:5556
  '';
}
