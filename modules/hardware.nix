# hardware: module for common hardware configuration.
# scope: bare-metal machines
#
# Not to be used on virtual machines.
{
  config,
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
