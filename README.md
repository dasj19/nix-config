# nix-config
Own nixos configurations

# Purpose
This repository servers my own needs and should not be used verbatim.
You can look and get inspired about how I use nixOS.
This was made public for the sole purpose of sharing configurations and inspire others.

# Contents
Each folder will contain the configuration for one server/machine.
So every folder is going to be symlinked to /etc/nixos on a given system.
Secrets are encoded with the help of agenix.
I hide public IPs, domain names, and other information I deem sensitive.

# Structure
Right now I am moving the configuration from host-based folders to module-based folders in order
to reuse configuration across machines and have the code as DRY as possible.
The "machines" folder will have the host configuration with each machine including a certain number of modules.
The "modules" folder contains reusable pieces of code, modules meant to be used across machines.
The "secrets" are moved at the root level.

# Machines

|   Hostname  | Brand and model  |   CPU              |  RAM  |   GPU(s)                | Role | OS  | State |
| :---------: | :--------------: | :----------------: | :---: | :---------------------: | :--: | :-: | :---: |
| contabo2    | Contabo KVM VPS  | AMD EPYC 7282      | 6  GB | Not Available           | ☁️    | ❄️   | ✅    |
| tuxedo-xa15 | Tuxedo Book XA15 | AMD Ryzen 3000     | 64 GB | NVIDIA GeForce RTX 2070 | 💻️   | ❄️   | ✅    |
| t500libre   | Lenovo T500      | Intel Core 2 T9600 | 8  GB | Disabled                | ☁️    | ❄️   | ✅    |
| xps13-9310  | Dell XPS13 9310  | ______________     | 32 GB | _______________________ | 💻️   | ❄️   | ✅    |
| xps13-9380  | Dell XPS13 9380  | Intel i7-8565U     | 8  GB | Intel UHD Graphics 620  | 💻️   | ❄️   | ✅    |


**Key**
- 🖥️ : Desktop
- 💻️ : Laptop
- 🎮️ : Games Machine
- 🐄 : Virtual Machine
- ☁️ : Server
- 🧟 : Not in service
