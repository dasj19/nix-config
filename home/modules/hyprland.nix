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
      hyprshot-print = "hyprshot -o ~/media/photos/";
      mute-mic-action = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && swayosd-client --input-volume mute-toggle";
      # Custom feedback actions. Icons list available here: https://specifications.freedesktop.org/icon-naming/latest/
      remove-action = "swayosd-client --custom-icon edit-delete --custom-message 'Removed'";
      home-action = "swayosd-client --custom-icon go-home --custom-message 'Home'";
      end-action = "swayosd-client --custom-icon go-last --custom-message 'End'";
      cut-action = "swayosd-client --custom-icon edit-cut --custom-message 'Cut'";
      copy-action = "swayosd-client --custom-icon edit-copy --custom-message 'Copied'";
      paste-action = "swayosd-client --custom-icon edit-paste --custom-message 'Pasted'";
      undo-action = "swayosd-client --custom-icon edit-undo --custom-message 'Undid'";
      redo-action = "swayosd-client --custom-icon edit-redo --custom-message 'Redone'";
      save-action = "swayosd-client --custom-icon document-save --custom-message 'Saving'";
      refresh-action = "swayosd-client --custom-icon view-refresh --custom-message 'Refreshing'";
    in

    ''
      env = GDK_BACKEND,wayland,x11,*
      # Monitor config.
      monitor = eDP-1, highres, 0x0, 1
      monitor = , preferred, auto, auto
      # prepare the network indicator
      exec-once = nm-applet --indicator
      # delay the launch of the bar
      exec-once = sleep 1 & waybar
      # Start the plugin system.
      exec-once = pypr

      # Position the windows of "Show me the key" always on the screen, floating at the bottom left.
      windowrule {
        name          = position-showmethekey
        match:class   = one.alynx.showmethekey
        match:title   = Floating\sWindow.*
        float         = on
        #center        = on
        pin           = on
        move          = (monitor_w*0.1) (monitor_h*0.9)
        max_size      = (monitor_w*0.4) (monitor_w*0.2)
        border_size   = 10
        border_color  = rgb(FF0000)
      }

      # Conditional styling.
      windowrule = border_color rgb(00FF00), match:fullscreen 1,  # Change fullscreen windows' borders to green.

      # Input settings.
      input {
        kb_layout=esrodk
      }

      # Launching Apps
      bind = ${modifier},         RETURN,                 exec,               ${terminal}                                 # Open terminal with Modifier + Return.
      bind = CTRL_L ALT_L,        T,                      exec,               ${terminal}                                 # Open terminal with Ctrl + Alt + T.
      bind = ${modifier},         B,                      exec,               ${browser}                                  # Open browser with Modifier + B.
      bind = ${modifier},         L,                      exec,               hyprlock                                    # Lock screen with Modifier + L.
      bind = CTRL_L,              SPACE,                  exec,               ulauncher                                   # Main App Launcher.

      # Desktop shortcuts.
      bind = CTRL_L SHIFT_L,      ESCAPE,                 exec,               GDK_BACKEND=x11 missioncenter               # Launch resource manager in xwayland mode.
      bind = CTRL_L SHIFT_L,      MASCULINE,              exec,               resources                                   # Launch another desktop resource manager.
      bind = CTRL_L SHIFT_L,      PLUS,                   exec,               pypr zoom +0.25                             # Zoom in on the desktop.
      bind = CTRL_L SHIFT_L,      MINUS,                  exec,               pypr zoom -0.25                             # Zoom out on the desktop.

      # Multimedia.
      bind = CTRL_L,              MASCULINE,              exec,               swayosd-client --playerctl play-pause       # Play-Pause with CTL + key above Tab.
      bind = CTRL_L SHIFT,        RIGHT,                  exec,               swayosd-client --playerctl next             # Next track.
      bind = CTRL_L SHIFT,        LEFT,                   exec,               swayosd-client --playerctl previous         # Previous track.
      bind =                   ,  XF86AudioRaiseVolume,   exec,               swayosd-client --output-volume raise        # Raise Volume with visuals.
      bind =                   ,  XF86AudioLowerVolume,   exec,               swayosd-client --output-volume lower        # Decrease volume with visuals.
      bind =                   ,  XF86AudioMute,          exec,               swayosd-client --output-volume mute-toggle  # Toggle mute with visuals.
      bind =                   ,  XF86AudioMicMute,       exec,               ${mute-mic-action}                          # Toggle microphone mute with visuals.

      # Single keys.
      bindr = CAPS             ,  Caps_Lock,              exec,               swayosd-client --caps-lock                  # Show visuals on Capslock toggle.
      bindn =                  ,  Delete,                 exec,               ${remove-action}                            # Show visuals on Delete key.
      bindn =                  ,  Home,                   exec,               ${home-action}                              # Show visuals on Home key.
      bindn =                  ,  End,                    exec,               ${end-action}                               # Show visuals on End key.

      # Popular actions.
      bindn = CTRL_L           ,  X,                      exec,               ${cut-action}                               # Show visuals when cutting.
      bindn = CTRL_L           ,  C,                      exec,               ${copy-action}                              # Show visuals when copying.
      bindn = CTRL_L           ,  V,                      exec,               ${paste-action}                             # Show visuals when pasting.
      bindn = CTRL_L           ,  Z,                      exec,               ${undo-action}                              # Show visuals when undoing.
      bindn = CTRL_L           ,  S,                      exec,               ${save-action}                              # Show visuals when saving.
      bindn = CTRL_L           ,  R,                      exec,               ${refresh-action}                           # Show visuals when refreshing (primary).
      bindn = CTRL_L           ,  Y,                      exec,               ${redo-action}                              # Show visuals when redoing (primary).
      bindn = CTRL_L SHIFT     ,  Z,                      exec,               ${redo-action}                              # Show visuals when redoing (duplicate).

      # Screenshot.
      bind =                   ,  PRINT,                  exec,               ${hyprshot-print} -m output -m active       # Screenshot the whole screen.
      bind = SHIFT_L,             PRINT,                  exec,               ${hyprshot-print} -m region                 # Activate region screen printing.
      bind = ALT_L,               PRINT,                  exec,               ${hyprshot-print} -m window -m active       # Screenshot the active window.

      # Brightness.
      bind =                   ,  XF86MonBrightnessDown,  exec,               swayosd-client --brightness lower           # Decrease screen brightness with visuals.
      bind =                   ,  XF86MonBrightnessUp,    exec,               swayosd-client --brightness raise           # Increase screen brightness with visuals.

      # Window management.
      bind = ALT,                 F4,                     killactive,                                                     # Gracefully Close Active Window (duplicate).
      bind = CTRL_L,              Q,                      killactive,                                                     # Gracefully Close Active Window (primary).
      bind = ${modifier} CTRL_L,  Left,                   movewindow,         l                                           # Move Window Left.
      bind = ${modifier} CTRL_L,  Right,                  movewindow,         r                                           # Move Window Right.
      bind = ${modifier} CTRL_L,  Up,                     movewindow,         u                                           # Move Window Up.
      bind = ${modifier} CTRL_L,  Down,                   movewindow,         d                                           # Move Window Down.
      bind = ${modifier},         LEFT,                   movefocus,          l                                           # Move focus to the Left.
      bind = ${modifier},         RIGHT,                  movefocus,          r                                           # Move focus to the Right.
      bind = ${modifier},         UP,                     movefocus,          u                                           # Move focus Up.
      bind = ${modifier},         DOWN,                   movefocus,          d                                           # Move focus Down.

      # Window tile management.
      binde = ${modifier},        COMMA,                  layoutmsg,          splitratio -0.1                             # Adjust Slit Ratio Decreasing current window. 
      binde = ${modifier},        PERIOD,                 layoutmsg,          splitratio +0.1                             # Adjust Slit Ratio Increasing current window.
      bind  = ${modifier},        F,                      fullscreen,         1                                           # Maximize.
      bind  = ${modifier} CTRL_L, F,                      togglefloating,                                                 # Float/Tile.
      bind  = ${modifier},        S,                      layoutmsg,          swapsplit                                   # Swap windows within their split area.ss

      # Window navigation.
      bind = ALT,                 TAB,                    cyclenext,                                                      # Change focus to next window.
      bind = ALT SHIFT,           TAB,                    cyclenext,          prev                                        # Change focus to previous window.

      # Workspace navigation.
      bind = ${modifier},         TAB,                    workspace,          e+1                                         # Change to next workspace (primary).
      bind = ${modifier} SHIFT,   TAB,                    workspace,          e-1                                         # Change to previous workspace (primary).

      # Alternative navigation. (consider removing)
      bind = CTRL_L ALT_L,        LEFT,                   workspace,          e-1                                         # Change to previous workspace (duplicate).
      bind = CTRL_L ALT_L,        RIGHT,                  workspace,          e+1                                         # Change to next workspace (duplicate).
      bind = ${modifier},         LEFT,                   workspace,          -1                                          # Change to previous workspace (duplicate).
      bind = ${modifier},         RIGHT,                  workspace,          +1                                          # Change to next workspace (duplicate).

      # Move focused window to next/previous workspace.
      bind = ${modifier} SHIFT,   LEFT,                   movetoworkspace,    -1                                          # Move window in focus to previous workspace.
      bind = ${modifier} SHIFT,   RIGHT,                  movetoworkspace,    +1                                          # Move window in focus to next workspace.

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
    # @todo: Dim the screen after 300 of inactivity.
  };
  # Pyprland plugin management tool.
  home.file.".config/hypr/pyprland.toml".source = (pkgs.formats.toml { }).generate "pyprland-config" {

    pyprland = {
      plugins = [ "magnify" ];
    };
  };

  # Display nice icons on screen for known special actions.
  services.swayosd = {
    enable = true;
    # OSD Margin from the top edge.
    topMargin = 0.9;
  };

}
