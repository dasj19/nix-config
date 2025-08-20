{ pkgs, ...}:
{
  config = {
    environment.systemPackages = with pkgs; [
      # Emulation.
      retroarchFull
      retroarch-assets

      # Games.
      mars
      superTux
      superTuxKart
      xonotic
      
      # Tools.
      evtest
      oversteer
      linuxConsoleTools
      gamepad-tool
      retroarch-joypad-autoconfig
      qjoypad
    ];
  };
}