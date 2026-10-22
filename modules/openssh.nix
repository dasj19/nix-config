# openssh: configuration for openssh server.
# scope: servers

{ config, ... }:

{
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PubkeyAuthentication = true;
  # Root may only log in with a key, never with a password.
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  services.openssh.extraConfig = "MaxAuthTries 10";
  # https://stackoverflow.com/questions/8250379/sftp-on-linux-server-gives-error-received-message-too-long
  services.openssh.sftpServerExecutable = "internal-sftp";

  # Public keys allowed to log in as the primary user, in addition to ~/.ssh/authorized_keys.
  users.users.${config.users.primaryUser}.openssh.authorizedKeys.keys = [
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBwDBtNViLPvD8qSVNZLo2Gr27ebrA9NFjtCqL/capFsu0cnA2hcC9zs0hNu7KVEUidzYwpPO/FhYUk7dDk83Kc= daniel@t14"
  ];

  # OpenSSH ports.
  services.openssh.ports = [
    22
  ];

  # Firewall.
  networking.firewall.allowedTCPPorts = [
    22 # OpenSSH.
  ];
}
