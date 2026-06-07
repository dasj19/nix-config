# openssh: configuration for openssh server.
# scope: servers

_ :
{
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PubkeyAuthentication = true;
  services.openssh.settings.PermitRootLogin = "yes";
  services.openssh.extraConfig = "MaxAuthTries 20";
  # https://stackoverflow.com/questions/8250379/sftp-on-linux-server-gives-error-received-message-too-long
  services.openssh.sftpServerExecutable = "internal-sftp";

  # OpenSSH ports.
  services.openssh.ports = [
    22
  ];

  # OpenSSH ports.
  networking.firewall.allowedTCPPorts = [
    22 # OpenSSH.
  ];
}