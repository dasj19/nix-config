{
  imports = [
    # Profiles.
    ./base.nix
  ];

  config = {

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;
    services.openssh.settings.PubkeyAuthentication = true;
    services.openssh.settings.PermitRootLogin = "yes";
    services.openssh.extraConfig = "MaxAuthTries 20";
    # https://stackoverflow.com/questions/8250379/sftp-on-linux-server-gives-error-received-message-too-long
    services.openssh.sftpServerExecutable = "internal-sftp";

    networking.firewall.allowPing = true;
    networking.firewall.pingLimit = "--limit 1/minute --limit-burst 5";

    # Don't build documentation on servers.
    documentation.enable = false;
    documentation.man.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;
    documentation.doc.enable = false;
    documentation.dev.enable = false;
  };
}