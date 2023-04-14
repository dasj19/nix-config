let
  root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII+HAdh3agY0DiWSzk2XWOSPEinwfPHa7V+MiWirkc1Q root@xps13-9310";
  users = [ root ];

  xps13-9310 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAMvAIajfL4jR3PXizY0yrVlDzKNliIGgh41+7Fcp/od";
  systems = [ xps13-9310 ];
in
{
  # Keep this list in alphabetical order.
  "localhost-account-daniel-fullname.age".publicKeys = [ root xps13-9310 ];
  #"localhost-account-daniel-password.age".publicKeys = [ root xps13-9310 ];
  #"localhost-account-root-password.age".publicKeys = [ root tuxedo ];
}
