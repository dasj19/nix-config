# waybar: Waybar status bar configuration.
# scope: laptops
#
# Provides Waybar settings, modules, and styling.

{
  lib,
  pkgs,
  ...
}:

let
  # A small tofi window in the center of the screen, the defaults (1280x720) are meant for long lists.
  tofi = builtins.concatStringsSep " " [
    "${pkgs.tofi}/bin/tofi"
    "--anchor=center"
    "--width=300"
    "--height=180"
    "--font-size=16"
    "--border-width=4"
    "--outline-width=2"
    "--corner-radius=8"
    "--padding-top=12"
    "--padding-bottom=12"
    "--padding-left=16"
    "--padding-right=16"
  ];

  # Power menu shown with tofi, every action asks for a confirmation first.
  # "No" is listed first in the confirmation so that pressing Enter or Escape cancels.
  powerMenu = pkgs.writeShellScript "power-menu" ''
    confirm() {
      [ "$(printf 'No\nYes\n' | ${tofi} --prompt-text="$1? ")" = "Yes" ]
    }

    case "$(printf 'Logout\nReboot\nPower off\n' | ${tofi} --prompt-text='Power: ')" in
      "Logout") confirm "Logout" && hyprctl dispatch 'hl.dsp.exit()' ;;
      "Reboot") confirm "Reboot" && systemctl reboot ;;
      "Power off") confirm "Power off" && systemctl poweroff ;;
    esac
  '';
in
{
  programs.waybar.enable = true;
  # Start with the graphical session, restarted by systemd if it crashes.
  programs.waybar.systemd.enable = true;
  # @TODO revert to pkgs.waybar once a release after 0.15.0 is in nixpkgs.
  # Waybar 0.15.0 switches workspaces with the legacy dispatch syntax, rejected by the Lua config of
  # Hyprland, so clicking a workspace does nothing. Fixed upstream in https://github.com/Alexays/Waybar/pull/5013
  # cava (audio visualizer module, unused) is disabled because master needs a newer libcava than nixpkgs.
  programs.waybar.package = (pkgs.waybar.override { cavaSupport = false; }).overrideAttrs (oldAttrs: {
    version = "0.15.0-unstable-2026-10-19";
    # New modem (wwan) module, unused and its modemmanager dependency is missing.
    mesonFlags = oldAttrs.mesonFlags ++ [ (lib.mesonEnable "wwan" false) ];
    # The version check expects the unstable version, but master still reports v0.15.0.
    doInstallCheck = false;
    src = pkgs.fetchFromGitHub {
      owner = "Alexays";
      repo = "Waybar";
      rev = "c15ec02ede4343592a59eb5c2ff4443c9c045f7c";
      hash = "sha256-mBDWjeeIuFfDZQuBxHu+EpbJ+GMbbSxpRz0WVM2N+ZI=";
    };
  });
  programs.waybar.settings = {
    mainBar = {
      layer = "top";
      position = "top";
      spacing = 4;
      margin-top = 5;
      margin-bottom = 5;
      height = 35;
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
        "disk"
        "custom/monitor-settings"
        "custom/projector-settings"
        "idle_inhibitor"
        "backlight"
        "bluetooth"
        "network"
        "wireplumber#sink"
        "wireplumber#source"
        "battery"
        "custom/power"
      ];

      backlight = {
        device = "intel_backlight";
        format = "{icon} {percent}%";
        tooltip-format = "Screen brightness: {percent}%";
        format-icons = [
          ""
          ""
        ];
      };

      battery = {
        format = "{icon} {capacity}%";
        # {timeTo} is "Empty in ...", "Full in ..." or the charging status.
        tooltip-format = ''
          {timeTo}
          Power draw: {power:.1f} W
          Health: {health}%
          Charge cycles: {cycles}'';
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
        # Open calendar in a floating window on click.
        on-click = "hyprctl dispatch 'hl.dsp.exec_cmd(\"orage --toggle\")'";
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
        tooltip-format = ''
          RAM: {used:0.1f}G used, {avail:0.1f}G available ({percentage}%)
          Swap: {swapUsed:0.1f}G / {swapTotal:0.1f}G ({swapState})'';
      };

      # Used space of the root filesystem, in GB.
      disk = {
        interval = 60;
        path = "/";
        unit = "GB";
        format = "💿 {specific_used:0.0f} GB";
        tooltip-format = "Disk {path}: {used} used of {total} ({percentage_used}%), {free} free";
      };

      "custom/monitor-settings" = {
        interval = "once";
        format = "🖥️";
        tooltip-format = "Monitor settings";
        on-click = ''
          hyprctl dispatch 'hl.dsp.exec_cmd("wlrlui")'
        '';
      };

      "custom/projector-settings" = {
        interval = "once";
        format = "📽️";
        tooltip-format = "Screen mirroring\nClick: mirror the laptop screen\nRight-click: stop mirroring";
        on-click = "hyprctl eval \"hl.monitor({ output = '', mode = 'preferred', position = 'auto', scale = 1, mirror = 'eDP-1' })\"";
        on-click-right = "hyprctl eval \"hl.monitor({ output = '', mode = 'preferred', position = 'auto', scale = 1, mirror='' })\"";
      };

      # Opens the tofi power menu with session and power actions.
      "custom/power" = {
        interval = "once";
        format = "⏻";
        tooltip-format = "Logout, reboot or power off";
        on-click = "${powerMenu}";
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
        tooltip-format-ethernet = ''
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
        tooltip-format = "Output: {node_name} ({volume}%)\nClick: volume control\nRight-click: mute";
        on-click = "pwvucontrol";
        on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        scroll-step = 5;
      };
      "wireplumber#source" = {
        node-type = "Audio/Source";
        format = " {volume}%";
        format-muted = "";
        tooltip-format = "Microphone: {node_name} ({volume}%)\nClick: volume control\nRight-click: mute";
        on-click = "pwvucontrol";
        on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        scroll-step = 5;
      };

      "wlr/taskbar" = {
        tooltip-format = "{title}";
        on-click = "activate";
        on-click-middle = "close";
      };

      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "👁️";
          deactivated = "🌠";
        };
        timeout = "30.5";
        tooltip-format-activated = "Idle inhibitor on: the screen stays awake";
        tooltip-format-deactivated = "Idle inhibitor off: the screen dims and locks when idle";
      };
    };
  };
}
