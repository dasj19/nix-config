let
  root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA6sdyQl04bE3ZBEPXQLtuRBXalxXI9YXuatSjCURfJI root@t500libre";
  users = [ root ];

  t500libre = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMJVtDuadSF2YmrmjIbAHaYeDIdn8jWAvg2S8RwQhS18 root@t500libre";
  systems = [ t500libre ];
in
{
  # Keep this list in alphabetical order.
  "localhost-account-daniel-password.age".publicKeys = [ root t500libre ];
  "localhost-account-root-password.age".publicKeys = [ root t500libre ];
  "mailserver-account-daniel-aliases.age".publicKeys = [ root t500libre ];
  "mailserver-account-daniel-password.age".publicKeys = [ root t500libre ];
  "mailserver-domains.age".publicKeys = [ root t500libre ];
  "sshserver-authorized-keys.age".publicKeys = [ root t500libre ];
}
