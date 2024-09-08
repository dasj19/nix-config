let
  root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB02AbFcfLJ5DbqRw2XoewessIAsROJQH8eBRzHxK/vc";
  users = [ root ];

  contabo2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINPaQ2k0Y5IDik2qoB0YIGePPQH2JFhWFDM/HvKodUTo";
  systems = [ contabo2 ];
in
{
  "cloudflare-dns-api-credentials.age".publicKeys = users ++ systems;
  "mailserver-account-daniel-password.age".publicKeys = users ++ systems;
}
