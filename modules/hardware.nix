# Module for common hardware configuration.
# To be used on bare metal / physical machines.
# Not to be used on virtual machines.
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # check S.M.A.R.T status of all disks and notify in case of errors.
  services.smartd.enable = true;
  services.smartd.notifications.mail.enable = true;
  services.smartd.notifications.mail.recipient = "daniel@${config.networking.hostName}.localdomain";
  services.smartd.notifications.test = false;

  # Setup a mail server to send notifications.
  services.postfix.enable = true;

  environment.systemPackages = with pkgs; [
    smartmontools # Control utility for SMART disks.
  ];
}
