{ pkgs, ...}:
{
  config = {
    environment.systemPackages = with pkgs; [
      # Emulation.
      # build fails: emulationstation-de
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

    nixpkgs.config.permittedInsecurePackages = [
      # Emulationstation depends on this.
      "freeimage-unstable-2021-11-01"
    ];
  };
}