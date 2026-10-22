# openssh: configuration for openssh server.
# scope: servers

_: {
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PubkeyAuthentication = true;
  # Root may only log in with a key, never with a password.
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  services.openssh.extraConfig = "MaxAuthTries 20";
  # https://stackoverflow.com/questions/8250379/sftp-on-linux-server-gives-error-received-message-too-long
  services.openssh.sftpServerExecutable = "internal-sftp";

  # OpenSSH ports.
  services.openssh.ports = [
    22
  ];

  # Firewall.
  networking.firewall.allowedTCPPorts = [
    22 # OpenSSH.
  ];
}
