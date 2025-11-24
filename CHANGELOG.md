# Changelog
In this file I'll try to mention major changes to the configuration.

2025-11-24
- hyprland: added packages that help with file thumbnails.
- hyprland: replaced kitty with alacritty.
- browsers: added wordnik search engine.

2025-11-23
- home laptop: add bluetooth manager to the waybar.
- home laptop: enhanced configuration of waybar widgets.
- home laptop: removed unused packages halloy and flacon.
- browsers: added customizations to chrome-based browsers.
- fish: use fastfetchMinimal instead of plain fastfetch.
- home laptop: customized wlr/taskbar plugin for the waybar.
- home laptop: customized the audio plugin for the waybar.
- fish: removed display of date after the shell launches.
- home: introduced modules for home manager.
- home: configuration split into hm modules.
- hyprland: upgrade from nemo to nemo-with-extensions

2025-11-22
- t14: removed configuration that enabled the Nvidia GPU, relying only on intel from now on
- stylix: changed the monospaced font from UbuntuMono to NotoMono
- hyprland: changed default programs for text editing, image viewer and pdf viewer
- browsers: added search engines: Wikipedia, Github, DuckDuckGo, NixOS Discourse, NixOS Wiki
- browsers: added comments for chromium settings
- browsers: disabled some more features from chromium
- home laptop: disabled editor minimap to gain screen estate

2025-11-18
- flake: added latest ulauncher for t14 (for now).
- home: added initial config for hyprlock for the laptop profile.
- home: updated keybindings for hyprland.

2025-11-17
- module: added hyprland wayland compositor to replace Gnome DE.

2025-11-16
- ai: temporary disabled shell-gpt and open-webui
- nix: moved from alejandra to the official nixfmt and added it at autosave in VSCodium

2025-11-11
- workflows: introduced build matrix, to parallel build all machines' configuration.
- workflows: added automatic check for dependency updates using dependabot.
- workflows: added monitoring of nix flake inputs using Renovate.
- flake: use github source for nix-compat

2025-11-10
- machines: added rpi4-tv as a new 64-bit arm server

2025-11-09
- flake: introduced mkDefaultSystem function to avoid repeating common flake configurations across machine definitions.
- workflows: updated github workflow dependencies
- workflows: pulled out the tuxedo-xa15 from the build pipeline
- flake: extracted common definitions in functions like mkDefaultSystem, mkLaptopSystem and mkServerSystem
- profiles: removed unused profile for office

2025-11-08
- t14: Inheriting a new hardware configuration from nixos-hardware, codename: lenovo-thinkpad-t14-intel-gen1-nvidia.
- flake: removed nix-alien as project dependency.
- flake: removed vscode-server as project dependency.
