{
  config,
  lib,
  pkgs,
  ...
}:
{
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

  # Add Kando to the list of autostart programs.
  xdg.configFile."autostart/kando.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Exec=kando
    Name=Kando Autostart
  '';

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
}
