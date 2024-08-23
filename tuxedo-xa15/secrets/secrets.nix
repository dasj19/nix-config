let
  root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIMFDEXLnL+99/Lfog/jvBn6p7tHS1fch62WGVMY2H28 root@tuxedo";
  users = [ root ];

  tuxedo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINkcDaA/f1oe+hR26P+gFzSVy7V6AnaaemhKGctL5fGJ";
  systems = [ tuxedo ];
in
{
  # Keep this list in alphabetical order.
  "localhost-account-daniel-fullname.age".publicKeys = [ root tuxedo ];
  "localhost-account-daniel-password.age".publicKeys = [ root tuxedo ];
  "localhost-account-root-password.age".publicKeys = [ root tuxedo ];
}
