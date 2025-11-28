{ pkgs, ... }:
{

  # Optional, hint Electron apps to use Wayland:
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  wayland.windowManager.hyprland.enable = true; # enable Hyprland
  wayland.windowManager.hyprland.xwayland.enable = true; # legacy support for X11 apps.
  wayland.windowManager.hyprland.systemd.enable = true; # systemd integration.
  wayland.windowManager.hyprland.extraConfig =
    let
      modifier = "SUPER";
      terminal = "${pkgs.alacritty}/bin/alacritty";
      browser = "${pkgs.firefox-devedition}/bin/firefox-devedition";
    in

    ''
      env = GDK_BACKEND,wayland,x11,*
      # Monitor config.
      monitor=eDP-1, highres, 0x0, 1
      monitor= , preferred, auto, auto
      # prepare the network indicator
      exec-once=nm-applet --indicator
      # delay the launch of the bar
      exec-once=sleep 1 & waybar

      # Input settings.
      input {
        kb_layout=esrodk
      }

      # Launching Apps
      bind = ${modifier},RETURN,exec,${terminal} # Open terminal with Super (Modifier) + Return.
      bind = CTRL_L ALT_L,T,exec,${terminal} # Open terminal with Ctrl + Alt + T.
      bind = ${modifier},B,exec,${browser} # Open browser (Firefox) with Super + B
      bind = ${modifier},L,exec,hyprlock # Lock screen with Super + L
      bind = ${modifier},SPACE,exec,kando --menu "Menu" # Secondary App launcher with Super + Space # uses electron, @todo consider removing
      bind = ${modifier},S, exec, walker # Too slow and buggy, consider removing.
      bind = CTRL_L, SPACE, exec, gapplication launch io.ulauncher.Ulauncher # Main App Launcher

      # Desktop shortcuts.
      bind = CTRL_L SHIFT_L, ESCAPE, exec, GDK_BACKEND=x11 missioncenter

      # Multimedia.
      bind = CTRL_L, MASCULINE, exec, playerctl play-pause # Play-Pause with CTL + key above Tab.
      bind = CTRL_L SHIFT, LEFT, exec, playerctl previous # Previous track
      bind = CTRL_L SHIFT, RIGHT, exec, playerctl next # Next track
      bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
      bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

      # Screenshot.
      bind = , PRINT, exec, hyprshot -m output -m active
      bind = SHIFT_L, PRINT, exec, hyprshot -m region
      bind = ALT_L, PRINT, exec, hyprshot -m window -m active

      # Brightness.
      bind = ,XF86MonBrightnessDown, exec, brightnessctl -d intel_backlight set 10%-
      bind = ,XF86MonBrightnessUp, exec, brightnessctl -d intel_backlight set 10%+

      # Window management.
      bind = ALT, F4, killactive, # Gracefully Close Active Window
      bind = CTRL_L, Q, killactive, # Gracefully Close Active Window
      bind = CTRL_L SUPER, Left, movewindow, l # Move Window Left
      bind = CTRL_L SUPER, Right, movewindow, r # Move Window Right
      bind = CTRL_L SUPER, Up, movewindow, u # Move Window Up
      bind = CTRL_L SUPER, Down, movewindow, d # Move Window Down
      bind = SUPER, LEFT, movefocus, l # Move focus to the Left
      bind = SUPER, RIGHT, movefocus, r # Move focus to the Right
      bind = SUPER, UP, movefocus, u # Move focus Up
      bind = SUPER, DOWN, movefocus, d # Move focus Down
      # Window tile management.
      binde = SUPER, COMMA, splitratio, -0.1 # Adjust Slit Ratio Decreasing current window 
      binde = SUPER, PERIOD, splitratio, +0.1  # Adjust Slit Ratio Increasing current window
      bind = SUPER, F, togglefloating, # Float/Tile
      bind = CTRL_L SUPER, F, fullscreen, 1 # Maximize

      # Workspace navigation.
      bind = ALT, TAB, workspace, e+1
      bind = ALT SHIFT, TAB, workspace, e-1

      bind = CTRL_L ALT_L, LEFT, workspace, e-1
      bind = CTRL_L ALT_L, RIGHT, workspace, e+1

      bind = ${modifier},LEFT,workspace, -1 # Change to previous workspace
      bind = ${modifier},RIGHT,workspace, +1 # Change to next workspace
      bind = ${modifier} SHIFT,LEFT,movetoworkspace, -1 # Move window in focus to previous workspace
      bind = ${modifier} SHIFT,RIGHT,movetoworkspace, +1 # Move window in focus to next workspace

      # 
    '';
  stylix.targets.hyprland.enable = true;

  # Enable system-wide terminal integration.
  xdg.terminal-exec.enable = true;
  # Set Simple Terminal as the default terminal emulator.
  xdg.terminal-exec.settings.default = [ "alacritty.desktop" ];

  # Enable terminal opening in nemo file manager.
  dconf.settings."org/cinnamon/desktop/applications/terminal" = {
    exec = "xdg-terminal-exec";
  };

  # Hyprland auto lock screen management.
  # @see https://wiki.hypr.land/Hypr-Ecosystem/hypridle/
  services.hypridle.enable = true;
  services.hypridle.settings = {
    # List of listeners. Only one supported for now.
    listener = {
      timeout = 150; # seconds of inactivity before locking.
      on-timeout = "pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances.
    };
  };

}
