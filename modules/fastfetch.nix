# fastfetch: fast system information display configuration.
# scope: all machines
#
# Provides the fastfetch package, config file, and shell startup hook.

{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.fastfetch.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Enable fastfetch system information display in shell startup.
    '';
  };

  config = lib.mkIf config.fastfetch.enable {
    environment.systemPackages = with pkgs; [
      fastfetch # Fast system information display.
      mailutils # Provides the 'mail' command for the fastfetch Mail module.
    ];

    # Fastfetch configuration for hardware overview.
    environment.etc."fastfetch/config.jsonc".source = pkgs.writeText "fastfetch-config.jsonc" ''
      {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
        "logo": {
          "type": "builtin"
        },
        "modules": [
          {
            "type": "title"
          },
          "separator",
          "os",
          "kernel",
          "uptime",
          "packages",
          "shell",
          "display",
          "de",
          "wm",
          "theme",
          "icons",
          "terminal",
          "cpu",
          "gpu",
          "memory",
          "swap",
          "disk",
          "localip",
          {
            "type": "command",
            "key": "Local Mail",
            "text": "mail -H 2>&1"
          },
          "battery"
        ]
      }
    '';
  };
}
