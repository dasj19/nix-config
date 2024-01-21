let
  root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEbzpxNNTeDv8gtQNgSndIU3qV4Ke0IPdS/gZo/qTWJ6";
  users = [ root ];

  linodenix2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAmY3Jmudp1R09ExCIPqBNozBTgczTrTiuov/yLu70WJ";
  systems = [ linodenix2 ];
in
{
  "cloudflare-dns-api-credentials.age".publicKeys = users ++ systems;
  "mailserver-account-daniel-password.age".publicKeys = users ++ systems;
}
