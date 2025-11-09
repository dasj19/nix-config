# Changelog
In this file I'll try to mention major changes to the configuration. 

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