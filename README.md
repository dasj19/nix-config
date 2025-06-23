# nix-config
Own nixos configurations

# Purpose
This repository servers my own needs and should not be used verbatim.
You can look and get inspired about how I use nixOS.
This was made public for the sole purpose of sharing configurations and inspire others.

# Contents
The configuration now uses flakes and each folder under **machines** contains configuration for one server/machine.
Secrets are encoded with the help of sopsnix.
Certain not-so-sensitive information is hidden using git-crypt.
I hide public IPs, domain names, and other information I deem sensitive.

# Structure
The configuration uses flakes and is modular in order
to reuse configuration across machines and have the code as DRY as possible.
The "machines" folder contains host configurations with one folder per machine machine. Usually only configuration.nix and hardware-configuration.nix is present here.
The "modules" folder contains reusable pieces of code, modules meant to be used across machines.
The "secrets" folder contains secrets that can be used globally across individual machine configurations.
The "profiles" folder contains a bare-bones profile where to start off when adding a new host to machines.
The "home" folder contains home-manager configurations.

# Usage

This repo holds configuration for NixOS machines I manage.
The basic actions I need to do to deploy on a local machine follows:

```
cd path/to/repo/files/nix-config
sudo nixos-rebuild switch --flake .#$(hostname) --print-build-logs
```
Or the short version (using the actual path and an alias defined in the aliases.nix module):
```
cd ~/workspace/projects/nix-config
osup
```
Behind the scenes there are some workflows actions that help building the packages on a NixOS server I control.
One action is responsible for building the packages for most of my machines.
Another is updating the flake definitions each morning and triggers the build package action.
Whenever I run *osup* on a machine that uses the builder.nix part of the building job is delegated
to the remote server that has updated builds of my configuration, thus making the build faster.
I also get emails when the automated build fails thus the failure does not propagate to all of the machines.

# Machines

|   Hostname  | Brand and model  |   CPU              |  RAM  |   GPU(s)                       | Role | OS  | State |
| :---------: | :--------------: | :----------------: | :---: | :----------------------------: | :--: | :-: | :---: |
| cm4-nas     | RaspberryPi CM4  | Cortex-A72         | 8  GB | Not Available                  | ☁️   | ❄️  | ✅    |
| contabo2    | Contabo KVM VPS  | AMD EPYC 7282      | 6  GB | Not Available                  | ☁️   | ❄️  | ✅    |
| t14         | Lenovo T14       | Intel i7-10610U    | 24 GB | NVIDIA GeForce MX330           | 💻️   | ❄️  | ✅    |
|             |                  |                    |       | Intel UHD Graphics (CML GT2)   |      |     |       |
| t500libre   | Lenovo T500      | Intel Core 2 T9600 | 8  GB | Disabled                       | ☁️   | ❄️  | ✅    |
| tuxedo-xa15 | Tuxedo Book XA15 | AMD Ryzen 3000     | 64 GB | NVIDIA GeForce RTX 2070        | 💻️   | ❄️  | ✅    |
| xps13-9380  | Dell XPS13 9380  | Intel i7-8565U     | 8  GB | Intel UHD Graphics 620         | 💻️   | ❄️  | ✅    |

**Key**
- 🖥️ : Desktop
- 💻️ : Laptop
- 🎮️ : Games Machine
- 🐄 : Virtual Machine
- ☁️ : Server
- 🧟 : Not in service
