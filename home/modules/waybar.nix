_: {
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
        "clock"
      ];
      modules-right = [
        "tray"
        "cpu"
        "memory"
        "backlight"
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
        # Open calendar in a floating window on click.
        on-click = ''hyprctl dispatch exec "[float; size:800 250; move: 1000 50] orage --toggle"'';
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
}
