{
  awesome-linux-templates,
  config,
  gitSecrets,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./base.nix
  ];

  # Install gnome extensions.
  # To be enabled in dconf.settings.enable-extensions.
  home.packages = with pkgs.gnomeExtensions; [
    # Visual window close effect.
    burn-my-windows
    # Clipboard manager.
    clipboard-indicator
    # Organize workspaces in a cube.
    desktop-cube
    # Kando menu integration.
    kando-integration
  ];

  # HM installs and manages itself.
  programs.home-manager.enable = true;

  programs.kitty.enable = true; # required for the default Hyprland config
  wayland.windowManager.hyprland.enable = true; # enable Hyprland
  wayland.windowManager.hyprland.xwayland.enable = true; # legacy support for X11 apps.
  wayland.windowManager.hyprland.systemd.enable = true; # systemd integration.
  wayland.windowManager.hyprland.extraConfig =
    let
      modifier = "SUPER"; # Windows key as modifier.
      terminal = "${pkgs.kitty}/bin/kitty";
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
      bind = ${modifier},RETURN,exec,${terminal} # Open terminal with Windows (Modifier) + Return.
      bind = ${modifier},B,exec,${browser} # Open browser (Firefox) with Windows + B
      bind = ${modifier},L,exec,hyprlock # Lock screen with Windows + L
      bind = ${modifier},SPACE,exec,kando --menu "Menu" # Secondary App launcher with Windows + Space # uses electron, @todo consider removing
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
      ptah = "screenshot";
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

  # Optional, hint Electron apps to use Wayland:
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  # Notification daemon for wayland.
  services.mako.enable = true;
  services.mako.settings.default-timeout = 5000;

  programs.waybar.enable = true;
  programs.waybar.settings = {
    mainBar = {
      layer = "top";
      position = "top";
      spacing = 4;
      margin-top = 5;
      margin-bottom = 5;
      height = 35;
      output = [
        "eDP-1"
        "HDMI-A-1"
      ];
      modules-left = [
        "hyprland/workspaces"
        "wlr/taskbar"
      ];
      modules-center = [
        "idle_inhibitor"
        "cpu"
        "memory"
        "backlight"
        "clock"
      ];
      modules-right = [
        "tray"
        "bluetooth"
        "network"
        "wireplumber#sink"
        "wireplumber#source"
        "battery"
      ];

      backlight = {
        device = "intel_backlight";
        format = "{icon} {percent}%";
        format-icons = [
          ""
          ""
        ];
      };

      battery = {
        format = "{icon} {capacity}%";
        format-icons = [
          " "
          " "
          " "
          " "
          " "
        ];
      };
      clock = {
        format = "{:%H:%M - %d-%m-%Y}";
        rotate = 0;
        format-alt = "{  %d·%m·%y}";
        tooltip-format = "<span>{calendar}</span>";
        calendar = {
          mode = "month";
          weeks-pos = "left";
          format = {
            months = "<span color='#ff6699'><b>{}</b></span>";
            days = "<span color='#cdd6f4'><b>{}</b></span>";
            weeks = "<span color='#99ffdd'><b>W{}</b></span>";
            weekdays = "<span color='#7CD37C'><b>{}</b></span>";
            today = "<span color='#ffcc66'><b>{}</b></span>";
          };
        };
      };

      "hyprland/workspaces" = {
        format = "{icon} : {name}";
        format-icons = {
          "1" = "";
          "2" = "";
          "3" = "";
          "4" = "";
          "5" = "";
          "active" = "";
          "default" = "";
        };
        persistent-workspaces = {
          "Virtual-1" = [
            1
            2
            3
            4
            5
          ];
        };
      };

      cpu = {
        interval = 30;
        format = "{icon0} {icon1} {icon2} {icon3} {icon4} {icon5} {icon6} {icon7}";
        format-icons = [
          "▁"
          "▂"
          "▃"
          "▄"
          "▅"
          "▆"
          "▇"
          "█"
        ];
      };

      memory = {
        interval = 30;
        format = "{used:0.1f}G / {total:0.1f}G ";
      };

      network = {
        tooltip = true;
        rotate = 0;
        format-ethernet = " ";
        tooltip-format = ''
          Network:          <b>{essid}</b>
          Signal strength:  <b>{signalStrength}%</b>
          Frequency:        <b>{frequency}MHz</b>
          Interface:        <b>{ifname}</b>
          IP:               <b>{ipaddr}</b>
          Gateway:          <b>{gwaddr}</b>
          Netmask:          <b>{netmask}</b>
        '';
        format-linked = " {ifname} (No IP)";
        format-disconnected = "󰖪 ";
        tooltip-format-disconnected = "Disconnected";
        format-alt = "<span foreground='#99ffdd'> {bandwidthDownBytes}</span> <span foreground='#ffcc66'> {bandwidthUpBytes}</span>";
        interval = 2;
      };

      bluetooth = {
        format = " {status}";
        format-connected = " {device_alias}";
        format-connected-battery = " {device_alias} {device_battery_percentage}%";
        tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
        tooltip-format-connected = ''
          {controller_alias}  {controller_address}
          {num_connections} devices connected
          {device_enumerate}
        '';
        tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
        tooltip-format-enumerate-connected-battery = ''
          {device_alias}  {device_address}  {device_battery_percentage}%
        '';
        on-click = "blueman-manager";
      };

      "wireplumber#sink" = {
        format = "{icon} {volume}%";
        format-muted = "";
        format-icons = [
          ""
          ""
          ""
        ];
        on-click = "pwvucontrol";
        on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        scroll-step = 5;
      };
      "wireplumber#source" = {
        node-type = "Audio/Source";
        format = " {volume}%";
        format-muted = "";
        on-click = "pwvucontrol";
        on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        scroll-step = 5;
      };

      "wlr/taskbar" = {
        tooltip-format = "{title}";
        on-click = "activate";
        on-click-middle = "close";
      };

      # "custom/hello-from-waybar" = {
      #   format = "hello {}";
      #   max-length = 40;
      #   interval = "once";
      #   exec = pkgs.writeShellScript "hello-from-waybar" ''
      #     echo "from within waybar"
      #   '';
      # };
    };
  };

  dconf.enable = true;
  # Define the available keyboard layouts.
  dconf.settings."org/gnome/desktop/input-sources".sources = [
    # Custom Spanish layout with extra 3rd level characters.
    (lib.hm.gvariant.mkTuple [
      "xkb"
      "esrodk"
    ])
    # Standard Spanish layout.
    (lib.hm.gvariant.mkTuple [
      "xkb"
      "es"
    ])
    # US layout.
    (lib.hm.gvariant.mkTuple [
      "xkb"
      "us"
    ])
    # Romanian layout.
    (lib.hm.gvariant.mkTuple [
      "xkb"
      "ro"
    ])
  ];

  # Media shortcuts. Using Ctrl instead of Fn (controlled by ACPI).
  # https://heywoodlh.io/nixos-gnome-settings-and-keyboard-shortcuts
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys" = {
    next = [ "<Ctrl>right" ];
    previous = [ "<Ctrl>left" ];
    play = [ "<Ctrl>masculine" ];
  };

  dconf.settings."org/gnome/desktop/interface" = {
    # Display date on the top bar.
    clock-show-date = true;
    # Display the weekday in the date close to the clock.
    clock-show-weekday = true;
    # Disable the default hot-corners.
    enable-hot-corners = false;
    # Display battery percentage on the top bar.
    show-battery-percentage = true;
    # Set text scaling below 100%.
    text-scaling-factor = 0.90;
    toolbar-icons-size = "small";
  };

  dconf.settings."org/gnome/desktop/peripherals/mouse" = {
    natural-scroll = true;
  };
  dconf.settings."org/gnome/desktop/peripherals/touchpad" = {
    natural-scroll = true;
    tap-to-click = true;
  };

  dconf.settings."org/gnome/desktop/notifications" = {
    # Disable notifications in the lock screen.
    show-in-lock-screen = false;
  };
  # Accessibility.
  dconf.settings."org/gnome/desktop/a11y" = {
    # Disable notifications in the lock screen.
    always-show-universal-access-status = true;
  };
  # Display week date (week number) in the top bar calendar.
  dconf.settings."org/gnome/desktop/calendar".show-weekdate = true;
  # Allow visual bell.
  dconf.settings."org/gnome/desktop/wm/preferences".visual-bell = true;
  # Gnome extensions.
  dconf.settings."org/gnome/shell" = {
    disable-user-extensions = false;

    # Active gnome-extensions.
    # Changes take effect after restarting gnome-shell / logging out.
    enabled-extensions = [
      "burn-my-windows@schneegans.github.com"
      "clipboard-indicator@tudmotu.com"
      "desktop-cube@schneegans.github.com"
      "kando-integration@kando-menu.github.io"
    ];
  };

  home.file."./.config/shell_gpt/.sgptrc".enable = true;
  home.file."./.config/shell_gpt/.sgptrc".text = ''
    DEFAULT_MODEL=ollama/deepseek-coder
    USE_LITELLM=true

    CHAT_CACHE_PATH=/tmp/chat_cache
    CACHE_PATH=/tmp/cache
    CHAT_CACHE_LENGTH=100
    CACHE_LENGTH=100
    REQUEST_TIMEOUT=60
    DEFAULT_COLOR=magenta
    ROLE_STORAGE_PATH=${config.home.homeDirectory}/.config/shell_gpt/roles
    DEFAULT_EXECUTE_SHELL_CMD=false
    DISABLE_STREAMING=false
    CODE_THEME=dracula
    OPENAI_FUNCTIONS_PATH=${config.home.homeDirectory}/.config/shell_gpt/functions
    OPENAI_USE_FUNCTIONS=true
    SHOW_FUNCTIONS_OUTPUT=false
    API_BASE_URL=default
    PRETTIFY_MARKDOWN=true
    SHELL_INTERACTION=true
    OS_NAME=auto
    SHELL_NAME=auto
    OPENAI_API_KEY=ollama
  '';

  # Setup a burn-my-windows profile.
  home.file."./.config/burn-my-windows/profiles/custom.conf".enable = true;
  home.file."./.config/burn-my-windows/profiles/custom.conf".text = ''
    [burn-my-windows-profile]
    paint-brush-enable-effect=false
    fire-enable-effect=false
    tv-enable-effect=true
  '';

  dconf.settings."org/gnome/shell/extensions/burn-my-windows" = {
    active-profile = "${config.home.homeDirectory}/.config/burn-my-windows/profiles/custom.conf";
  };

  programs.vscode.enable = true;
  programs.vscode.package = pkgs.vscodium;
  programs.vscode.mutableExtensionsDir = false;

  # Extensions enabled in VS Codium.
  programs.vscode.profiles.default.extensions =
    with pkgs.vscode-extensions;
    [
      # Github Copilot.
      github.copilot

      # PHP.
      bmewburn.vscode-intelephense-client

      #Codeium.codeium
      # Nix language support.
      jnoortheen.nix-ide

      # Spell checker.
      streetsidesoftware.code-spell-checker

      # Editor enhancements.
      oderwat.indent-rainbow
    ]
    ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      # Twig language support.
      {
        name = "twig-language";
        publisher = "mblode";
        version = "0.9.4";
        hash = "sha256-TZRjodIQkgFlPlMaZs3K8Rrcl9XCUaz4/vnIaxU+SSA=";
      }
      {
        name = "symfony-extension-pack";
        publisher = "nadim-vscode";
        version = "1.2.0";
        hash = "sha256-y3mkrWhlICOiFHZip3AGNDGNCvzo8FFRhhyHMu8E4yI=";
      }
      {
        name = "php-intellisense";
        publisher = "felixfbecker";
        version = "2.3.14";
        hash = "sha256-N5il3hFytYA4dzV9AFfj4SnY2CuPvgtTrijHd6AHXKY=";
      }
    ];

  programs.vscode.profiles.default.userSettings = {
    # Disable editor minimap.
    "editor.minimap.enabled" = false;
    # Startup empty.
    "workbench.startupEditor" = "none";
    # Set default tab size.
    "[php]"."editor.tabSize" = 2;

    # Spell checker.
    "cSpell.language" = "en";
    "cSpell.enabledFileTypes"."nix" = true;

    # Nix language.
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = "nil";
    "nix.formatterPath" = "nixfmt";

    # Autoformat Nix files on save.
    "editor.formatOnSave" = true;
    "editor.formatOnType" = false;
    "editor.formatOnPaste" = false;

    # Github Copilot.
    # @see https://github.com/VSCodium/vscodium/discussions/1487
    "github.copilot.enable" = {
      "*" = true;
      "markdown" = false;
      "plaintext" = false;
      "json" = false;
      "yaml" = false;
      "nix" = true;
      "shellscript" = true;
      "php" = true;
      "twig" = true;
    };
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "vscode-extension-bmewburn-vscode-intelephense-client"
      "vscode-extension-github-copilot"
    ];

  # Add Kando to the list of autostart programs.
  xdg.configFile."autostart/kando.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Exec=kando
    Name=Kando Autostart
  '';

  # Populate linux user templates.
  home.file."awesome-linux-templates" = {
    target = "./system/templates";
    source = "${awesome-linux-templates}/templates";
    recursive = true;
  };
}
