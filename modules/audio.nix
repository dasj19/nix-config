# audio: system-wide sound settings.
# scope: desktop

_:
{
  # Pipewire can acquire real time priority with rtkit.
  security.rtkit.enable = true;
  # Disable pulseaudio.
  services.pulseaudio.enable = false;
  # Enable sound with pipewire.
  services.pipewire.enable = true;
  services.pipewire.audio.enable = true;
  services.pipewire.pulse.enable = true;
  services.pipewire.jack.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.alsa.support32Bit = true;
}