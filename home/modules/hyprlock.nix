{
  gitSecrets,
  ...
}:
{
  # Enable and setup hyprlock.
  programs.hyprlock.enable = true;
  programs.hyprlock.settings = {
    auth = {
      "fingerprint:enabled" = true;
      "fingerprint:ready_message" = "Ready to scan fingerprints";
      "fingerprint:present_message" = "Scanning fingerprint";
    };
    background = {
      monitor = "";
      blur_passes = 3;
    };
    input-field = {
      monitor = "";
      size = "10%, 30%";
      outline_thickness = 3;
      dots_center = true;

      fade_on_empty = false;
      rounding = 15;

      font_family = "$font";
      placeholder_text = "Input password...";
      fail_text = "$PAMFAIL";

      dots_text_format = "*";
      dots_size = 0.4;
      dots_spacing = 0.3;

      position = "0, -20";
      halign = "center";
      valign = "center";
    };
    # Current date.
    label = [
      {
        monitor = "";
        text = ''cmd[update:18000000] echo "<b> "$(date +'%A, %-d %B %Y')" </b>"'';
        color = "rgba(00ff99ee)";
        font_size = 34;
        halign = "center";
        valign = "top";
      }
      # Recovery message.
      {
        monitor = "";
        text = "If found return to the owner! ${gitSecrets.danielFullname} ${gitSecrets.danielPersonalEmail} ${gitSecrets.danielPhoneNumber}";
        font_size = 28;
        halign = "center";
        valign = "bottom";
      }
    ];
  };
}
