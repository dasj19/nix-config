# nix-config
A collection of (ever changing) nixos configurations used locally and in production.

# Status
CI: ![](https://github.com/dasj19/nix-config/actions/workflows/build.yml/badge.svg)
QA: ![](https://github.com/dasj19/nix-config/actions/workflows/quality-assurance.yml/badge.svg)

# Purpose
This repository servers my own needs and should not be used verbatim.
You can look and get inspired about how I use NixOS.
This was made public for the sole purpose of sharing configurations and inspire others.

# Contents
* The configuration now uses flakes and each folder under **machines** contains configuration for one server/machine.
* Secrets are encoded with the help of sopsnix.
* Certain not-so-sensitive information is hidden using git-crypt.
* I hide public IPs, domain names, and other information I deem sensitive.

# Structure
The configuration uses flakes and is modular in order
to reuse configuration across machines and have the code as DRY as possible.
The "machines" folder contains host configurations with one folder per machine.
Usually only configuration.nix and hardware.nix is present here.
The "modules" folder contains reusable pieces of code, modules meant to be used across machines.
The "secrets" folder contains secrets that can be used globally across individual machine configurations.
The "profiles" folder contains configuration profiles used to kickstart a new host machine.
The "home" folder contains home-manager configurations.

# Usage

This repo holds configuration for NixOS machines I manage.
The command I need to run to deploy on a local machine follows:

```
sudo nixos-rebuild switch --flake .#$(hostname) --print-build-logs
```
Or the short version (using the shell alias defined in the aliases.nix module):
```
osup
```
Lately I moved on to using *nh* command to deploy:
```
nh os switch .#nixosConfigurations.$(hostname)
```
or using the alias from aliases.nix:
```
nhup
```
Behind the scenes there are some workflows actions that help building the packages on a NixOS server I control.
One action is responsible for building the packages of my machines.
Another is updating the flake definitions each morning and triggers the build package action.
Whenever I run *osup* or *nhup* on a machine that uses the builder.nix part of the building job is delegated
to the remote server that has updated builds of my configuration, thus making the build faster.
I also get emails when the automated build fails thus I avoid the failure propagating to all of the machines.

# Secrets
Passwords are managed using sops-nix.
Rest of the secrets that are not to be shared in git are protected using git-crypt.
The sops and git-crypt decryption keys are to be found on the individual machines and need to be copied manually.

Sops key in: `~/.config/sops/age/keys.txt`.

Git-crypt key: `git-crypt-key`

# Legend
**Status**
- ✅: Good for now
- 🚧: WIP
- 🚫: Blocked
- ❓: Undecided

**Hardware**
- 🖥️ : Desktop
- 💻️ : Laptop
- 🎮️ : Games Machine
- 🐄 : Virtual Machine
- ☁️ : Server
- 🧟 : Not in service

**Programming Language**
- 🔥: Mojo
- 🐍: Python
- ❄️: Nix
- 🦀: Rust
- 🐹: Go
- 💣: C/C++
- 🐒: ECMAScript
- 🫘: Java/Kotlin
- 🌙: Lua
- λ: Haskell
- 🦎: Pascal
- 🐚: Shellscript



# Machines

|   Hostname  | Brand and model  |   CPU                |  RAM  |   GPU(s)                       | Role | OS  | State | Location  |
| :---------: | :--------------: | :------------------: | :---: | :----------------------------: | :--: | :-: | :---: | :-------: |
| cm4-nas     | RaspberryPi CM4  | Cortex-A72           | 8  GB | Not Available                  | ☁️   | ❄️  | ✅    |     🏠    |
| contabo2    | Contabo KVM VPS  | AMD EPYC 7282        | 6  GB | Not Available                  | ☁️   | ❄️  | ✅    |     🇩🇪    |
| devbox      | Virtualbox       |                      | 4  GB | Not Available                  | 🐄   | ❄️  | ✅    |     🏠    |
| ideapad100  | Lenovo Ideapad100| Intel Pentium N3540  | 4  GB | Intel Atom                     | ☁️   | ❄️  | ✅    |     🏠    |
| linodenix1  | Linode Nanode    | AMD EPYC 7601        | 1  GB | Not Available                  | ☁️   | ❄️  | ✅    |     🇩🇪    |
| linodenix2  | Linode Nanode    | AMD EPYC 7713        | 1  GB | Not Available                  | ☁️   | ❄️  | ✅    |     🇩🇪    |
| hostup1     | HostUp VPS       | AMD EPYC-Milan       | 16 GB | Not Available                  | ☁️   | ❄️  | ✅    |     🇸🇪    |
| rpi4-tv     | RaspberryPi 4    |                      | 8  GB | Not Available                  | ☁️   | ❄️  | ✅    |     🏠    |
| t14         | Lenovo T14       | Intel i7-10610U      | 24 GB | NVIDIA GeForce MX330           | 💻️   | ❄️  | ✅    |     🏠    |
|             |                  |                      |       | Intel UHD Graphics (CML GT2)   |      |     |       |           |
| t500libre   | Lenovo T500      | Intel Core 2 T9600   | 8  GB | Disabled                       | ☁️   | ❄️  | ✅    |     🇩🇰    |
| tuxedo-xa15 | Tuxedo Book XA15 | AMD Ryzen 3000       | 64 GB | NVIDIA GeForce RTX 2070        | 💻️   | ❄️  | ✅    |     🏠    |

# Server Software

| Status | Component                    | Current                            | R&D                   | Legacy                    |
| :----: | :--------------------------: | :--------------------------------: | :-------------------: | :-----------------------: |
|   ✅   | Operating System             | NixOS ❄️                           |                       | Debian/Ubuntu             |
|   ✅   | Text Editor                  | nano 💣                            |                       |                           |
|   ✅   | Web Browser                  | w3m 💣                             | w3m plugins           |                           |
|   ✅   | Resource Downloader          | wget 💣 curl 💣                    |                       |                           |
|   🚧   | Version Control Software     | git 💣                             | jujutsu 🦀            |                           |
|   🚧   | File Manager                 | lf 🐹                              | nnn 💣                | mc 💣                     |
|   🚧   | Diff Manager                 | batdiff 🐚                         | difftastic 🦀         |                           |
|   ✅   | Compression Utilities        | tar 💣 xz 💣 unzip 💣              |                       |                           |
|   ✅   | Secret Management            | git-crypt 💣 sops 🐹               |                       | age 🐹                    |
|   🚧   | Terminal Multiplexer         | tmux 💣                            | screen 💣             |                           |
|   ✅   | Webserver                    | caddy 🐹                           |                       | apache2 💣 nginx 💣       |
|   ✅   | Mailserver (Groupware)       | Simple NixOS Mailserver ❄️         |                       |                           |
|   ✅   | Database server              | mariadb 💣 postgresql 💣 sqlite 💣 |                       |                           |

# Laptop Software
| Status | Component                    | Current                            | R&D                   | Legacy                    |
| :----: | :--------------------------: | :--------------------------------: | :-------------------: | :-----------------------: |
|   ✅   | Operating System             | NixOS ❄️                           |                       | Debian/Ubuntu             |
|   🚧   | Desktop Environment          | Hyprland 💣                        |                       | GNOME                     |
|   🚧   | Application Launcher         | Ulauncher 🐍                       | Ulauncher Extensions  | Gnome Shell 💣🐒 kando 🐒 |
|   🚧   | Terminal Client              | Alacritty 🦀                       | Wave 🐹               | Gnome Terminal 💣         |
|   🚧   | File Manager                 | Nemo 💣                            | Sigma File Manager 💣 | Nautilus 💣               |
|   ✅   | Music Player (Playlists)     | Strawberry 💣                      |                       | Clementine 💣             |
|   ✅   | Music Player (Albums)        | Tauon 🐍                           |                       |                           |
|   ✅   | Video Player                 | vlc 💣 mpv 💣                      |                       | Totem 💣                  |
|   ✅   | Code Editor (IDE)            | VS Codium 🐒                       |                       | Atom 🐒                   |
|   🚧   | Text editor                  | Textadept 🌙                       |                       | Gnome Text Editor 💣      |
|   🚧   | PDF Viewer                   | Xreader 💣                         |                       | Evince 💣                 |
|   ✅   | PDF Editor                   | Xournal++ 💣                       |                       |                           |
|   ✅   | Web Browser (Primary)        | Firefox Developer Edition 💣🐒     |                       |                           |
|   ✅   | Web Browser (Secondary)      | Chromium 💣                        |                       |                           |
|   🚧   | Office Suite                 | Only Office 💣                     |                       | LibreOffice 💣            |
|   ✅   | Diagram Drawing Tool         | drawio 🐒                          |                       |                           |
|   🚧   | Graphic Manipulation Tool    | GIMP 💣                            |                       |                           |
|   🚧   | Vector Graphic Tool          | ???                                |                       |                           |
|   🚧   | Resource Monitor             | Mission Center 💣 resources 🦀     |                       | Gnome System Monitor 💣   |
|   🚧   | Secret Management Tool       | Gnome Keyring 💣                   |                       |                           |
|   🚧   | Image Viewer                 | Image Roll 🦀                      |                       | Gnome Loupe 🦀            |
|   🚧   | Email client                 | Evolution 💣                       | Mailspring 🐒         |                           |
|   🚧   | Compression Tool             | Xarchiver 💣 File-roller 💣        |                       | Peazip 🦎                 |
|   ✅   | Personal messenger           | Signal Desktop 🐒                  |                       |                           |
|   ✅   | Community messenger          | Element 🐒                         |                       |                           |
|   ✅   | Virtualization               | virt-manager 🐍                    |                       | VirtualBox 💣             |
|   ✅   | File Transfer Tool           | Filezilla 💣                       |                       |                           |
|   ✅   | Database Management Tool     | dbeaver 🫘                         |                       |                           |
|   ✅   | Diff Manager                 | meld 🐍                            |                       |                           |
|   🚧   | CLI AI Agent                 | copilot-cli 🐒                     | claude-code 🐚        |                           |