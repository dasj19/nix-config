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
