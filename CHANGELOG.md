# Changelog
In this file I'll try to mention major changes to the configuration. 

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
