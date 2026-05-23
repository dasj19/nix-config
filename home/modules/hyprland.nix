{ pkgs, ... }:
{

  # Optional, hint Electron apps to use Wayland:
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  wayland.windowManager.hyprland.enable = true; # enable Hyprland
  wayland.windowManager.hyprland.xwayland.enable = true; # legacy support for X11 apps.
  wayland.windowManager.hyprland.systemd.enable = true; # systemd integration.
  wayland.windowManager.hyprland.extraConfig =    
  ''
    hl.env("GDK_BACKEND", "wayland")

    -- Monitor config.
    hl.monitor({
      output = "eDP-1",
      mode = "highres",
      position = "0x0",
      scale = "1",
    })

    hl.monitor({
      output = "",
      mode = "preferred",
      position = "auto",
      scale = "auto",
    })

    -- Position the windows of "Show me the key" always on the screen, floating at the bottom left.
    hl.window_rule({
      name = "position-showmethekey",
      match = {
        class = "one.alynx.showmethekey",
        title = "Floating\\sWindow.*",
      },
      float = true,
      --center        = on
      pin = true,
      move = "(monitor_w*0.1) (monitor_h*0.9)",
      --max_size      = (monitor_w*0.4) (monitor_w*0.2)
      --border_size   = 10
      --border_color  = rgb(FF0000)
    })

    -- Launching Apps.
    hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("alacritty"))
    hl.bind("SUPER + B", hl.dsp.exec_cmd("firefox-devedition"))
    hl.bind("SUPER + L", hl.dsp.exec_cmd("hyprlock"))
    hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd("alacritty"))
    hl.bind("CTRL + ALT + F", hl.dsp.exec_cmd("nemo"))
    hl.bind("CTRL + SPACE", hl.dsp.exec_cmd("ulauncher"))

    -- Desktop shortcuts.
    hl.bind("CTRL + SHIFT + ESCAPE", hl.dsp.exec_cmd("GDK_BACKEND=x11 missioncenter"))
    hl.bind("CTRL + SHIFT + MASCULINE", hl.dsp.exec_cmd("resources"))
    hl.bind("CTRL + SHIFT + PLUS", hl.dsp.exec_cmd("pypr zoom +0.25"))
    hl.bind("CTRL + SHIFT + MINUS", hl.dsp.exec_cmd("pypr zoom -0.25"))

    -- Multimedia.
    hl.bind("CTRL + MASCULINE", hl.dsp.exec_cmd("swayosd-client --playerctl play-pause"))
    hl.bind("CTRL + SHIFT + RIGHT", hl.dsp.exec_cmd("swayosd-client --playerctl next"))
    hl.bind("CTRL + SHIFT + LEFT", hl.dsp.exec_cmd("swayosd-client --playerctl previous"))
    hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"))
    hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"))
    hl.bind("XF86AudioMute", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"))
    hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && swayosd-client --input-volume mute-toggle"))

    -- Single keys.
    hl.bind("CAPS + Caps_Lock", hl.dsp.exec_cmd("swayosd-client --caps-lock"), { release = true })
    hl.bind("Delete", hl.dsp.exec_cmd("swayosd-client --custom-icon edit-delete --custom-message 'Removed'"), { non_consuming = true })
    hl.bind("Home", hl.dsp.exec_cmd("swayosd-client --custom-icon go-home --custom-message 'Home'"), { non_consuming = true })
    hl.bind("End", hl.dsp.exec_cmd("swayosd-client --custom-icon go-last --custom-message 'End'"), { non_consuming = true })

    -- Popular actions.
    -- Custom feedback actions. Icons list available here: https://specifications.freedesktop.org/icon-naming/latest/
    hl.bind("CTRL + X", hl.dsp.exec_cmd("swayosd-client --custom-icon edit-cut --custom-message 'Cut'"), { non_consuming = true })
    hl.bind("CTRL + C", hl.dsp.exec_cmd("swayosd-client --custom-icon edit-copy --custom-message 'Copied'"), { non_consuming = true })
    hl.bind("CTRL + V", hl.dsp.exec_cmd("swayosd-client --custom-icon edit-paste --custom-message 'Pasted'"), { non_consuming = true })
    hl.bind("CTRL + Z", hl.dsp.exec_cmd("swayosd-client --custom-icon edit-undo --custom-message 'Undid'"), { non_consuming = true })
    hl.bind("CTRL + S", hl.dsp.exec_cmd("swayosd-client --custom-icon document-save --custom-message 'Saving'"), { non_consuming = true })
    hl.bind("CTRL + R", hl.dsp.exec_cmd("swayosd-client --custom-icon view-refresh --custom-message 'Refreshing'"), { non_consuming = true })
    hl.bind("CTRL + Y", hl.dsp.exec_cmd("swayosd-client --custom-icon edit-redo --custom-message 'Redone'"), { non_consuming = true })
    hl.bind("CTRL + SHIFT + Z", hl.dsp.exec_cmd("swayosd-client --custom-icon edit-redo --custom-message 'Redone'"), { non_consuming = true })

    -- Screenshot.
    hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -o ~/media/photos/ -m output -m active"))
    hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("hyprshot -o ~/media/photos/ -m region"))
    hl.bind("ALT + PRINT", hl.dsp.exec_cmd("hyprshot -o ~/media/photos/ -m window -m active"))

    -- Brightness.
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"))
    hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness raise"))

    -- Window management.
    hl.bind("ALT + F4", hl.dsp.window.close())
    hl.bind("CTRL + Q", hl.dsp.window.close())
    hl.bind("SUPER + CTRL + Left", hl.dsp.window.move({ direction = "l" }))
    hl.bind("SUPER + CTRL + Right", hl.dsp.window.move({ direction = "r" }))
    hl.bind("SUPER + CTRL + Up", hl.dsp.window.move({ direction = "u" }))
    hl.bind("SUPER + CTRL + Down", hl.dsp.window.move({ direction = "d" }))
    hl.bind("SUPER + LEFT", hl.dsp.focus({ direction = "left" }))
    hl.bind("SUPER + RIGHT", hl.dsp.focus({ direction = "right" }))
    hl.bind("SUPER + UP", hl.dsp.focus({ direction = "up" }))
    hl.bind("SUPER + DOWN", hl.dsp.focus({ direction = "down" }))

    -- Window tile management.
    hl.bind("SUPER + COMMA", hl.dsp.layout("splitratio -0.1"), { repeating = true })
    hl.bind("SUPER + PERIOD", hl.dsp.layout("splitratio +0.1"), { repeating = true })
    hl.bind("SUPER + F", hl.dsp.window.fullscreen(1))
    hl.bind("SUPER + CTRL + F", hl.dsp.window.float({ action = "toggle" }))
    hl.bind("SUPER + S", hl.dsp.layout("swapsplit"))

    -- Window navigation.
    hl.bind("ALT + TAB", hl.dsp.window.cycle_next(""))
    hl.bind("ALT + SHIFT + TAB", hl.dsp.window.cycle_next("prev"))

    -- Workspace navigation.
    hl.bind("SUPER + TAB", hl.dsp.focus({ workspace = "e+1" }))
    hl.bind("SUPER + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }))

    -- Alternative navigation. (consider removing)
    hl.bind("CTRL + ALT + LEFT", hl.dsp.focus({ workspace = "e-1" }))
    hl.bind("CTRL + ALT + RIGHT", hl.dsp.focus({ workspace = "e+1" }))
    hl.bind("SUPER + LEFT", hl.dsp.focus({ workspace = -1 }))
    hl.bind("SUPER + RIGHT", hl.dsp.focus({ workspace = "+1" }))

    -- Move focused window to next/previous workspace.
    hl.bind("SUPER + SHIFT + LEFT", hl.dsp.window.move({ workspace = -1 }))
    hl.bind("SUPER + SHIFT + RIGHT", hl.dsp.window.move({ workspace = "+1" }))

    hl.config({
      decoration = {
        shadow = {
          color = "rgba(00000099)",
        },
      },
      general = {
        col = {
          active_border = "rgb(4136d9)",
          inactive_border = "rgb(593380)",
        },
      },
      group = {
        groupbar = {
          col = {
            active = "rgb(4136d9)",
            inactive = "rgb(593380)",
          },
          text_color = "rgb(b08ae6)",
        },
        col = {
          border_active = "rgb(4136d9)",
          border_inactive = "rgb(593380)",
          border_locked_active = "rgb(40dfff)",
        },
      },
      misc = {
        background_color = "rgb(000000)",
        disable_hyprland_logo = true,
      },

      -- Input settings.
      input = {
        kb_layout = "esrodk",
      },
    })

    hl.on("hyprland.start", function()
      -- prepare the network indicator
      hl.exec_cmd("nm-applet --indicator")
      -- delay the launch of the bar
      hl.exec_cmd("sleep 1 & waybar")
      -- Start the plugin system.
      hl.exec_cmd("pypr")
    end)
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
