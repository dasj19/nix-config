# AGENTS.md

Coding conventions and project-specific guidance for this repository.

## Project Structure

```
.
├── flake.nix                 # Flake entrypoint, mkServerSystem/mkLaptopSystem helpers
├── flake.lock                # Pinned flake inputs
├── .github/workflows/        # CI: quality-assurance.yml (lint) + build.yml (builds)
├── modules/                  # Shared NixOS modules, imported by machine configs
│   ├── acme.nix              # ACME/Cloudflare DNS + sops secrets
│   ├── ai.nix                # ollama, llama-cpp, open-webui
│   ├── aliases.nix           # Fish shell abbreviations + aliases
│   ├── audio.nix             # PipeWire audio
│   ├── bluetooth.nix         # Bluetooth configuration
│   ├── browsers.nix          # Firefox, Chromium and other browser's preferences
│   ├── builder.nix           # Remote build machine config (hostup1)
│   ├── cuda-packages.nix     # Module option: config.cuda.allowedPackages
│   ├── email-server.nix      # Mailserver base config + rspamd
│   ├── fastfetch.nix         # Fast system information display
│   ├── fish.nix              # Fish shell + plugins
│   ├── folders.nix           # XDG user directories
│   ├── games.nix
│   ├── gnome.nix
│   ├── hardware.nix          # Generic hardware detection + SMART + mail utils
│   ├── hyprland.nix
│   ├── keyboard.nix
│   ├── locale.nix
│   ├── nix.nix               # Nix daemon and nix-related config
│   ├── non-free.nix          # allowUnfreePredicate + allowedUnfree option
│   ├── openssh.nix
│   ├── php-fpm.nix           # Module option: config.services.phpfpm.defaultPoolSettings
│   ├── starship.nix          # Shell prompt configuration
│   ├── stylix.nix
│   └── users.nix
├── settings/                 # Static configuration files (keyboard layouts, etc.)
│   └── esrodk                # Custom XKB keyboard layout (Spanish with RODK) #cspell:disable-line
├── machines/                 # One folder per machine
│   ├── <hostname>/
│   │   ├── configuration.nix # Main config, imports modules + profiles
│   │   ├── hardware.nix      # Hardware-specific config (from nixos-generate-config)
│   │   └── ...               # Optional extra configs (email.nix, caddy.nix, etc.)
├── profiles/                 # Shared machine profiles
│   ├── base.nix              # Base profile imported by server.nix and laptop.nix
│   ├── server.nix
│   └── laptop.nix
├── home/                     # Home Manager configs
│   ├── modules/              # Shared home-manager modules
│   └── profiles/             # Per-profile home configs
├── secrets/                  # SOPS + git-crypt encrypted secrets
├── pkgs/                     # Custom packages
│   ├── caddy-browse.nix
│   └── fish-colored-man.nix  # Local fish plugin, pending upstream submission
├── .pre-commit-config.yaml   # Pre-commit hooks: nixfmt + statix
├── .editorconfig             # Editor config: 2-space indent, LF, trim whitespace
├── renovate.json             # Automated dependency updates (Renovate bot)
├── statix.toml               # Statix linter configuration
├── git-crypt-key             # git-crypt symmetric key (git-crypt encrypted)
├── AGENTS.md                 # This file
└── README.md
```

## NixOS Module Conventions

- **Header format**: first line is `# module-name: short description.`, second line is `# scope: ...`, from the third line on more details are presented.
- **Shorthand style**: use `_:` for unused args, not `{ ... }:` (statix requires `_`).
- **No `config = { ... }` wrapper** unless the module declares `options` and needs `config` to reference them (like `non-free.nix`, `cuda-packages.nix`, `php-fpm.nix`).
- **Ordering of elements**: order the elements in `imports` and `environment.systemPackages` alphabetically.
- **Module options over specialArgs**: prefer declaring `options` in a module and importing it. Only use `specialArgs` for truly global values that cannot be module options (currently: `gitSecrets`, `sopsSecrets`).
- **ACME secrets**: always import `modules/acme.nix` on machines that use `security.acme` or `mailserver.x509.useACMEHost`. The module provides the sops secret declarations and Cloudflare DNS defaults.
- **PHP-FPM settings**: import `modules/php-fpm.nix` and merge with `// config.services.phpfpm.defaultPoolSettings`.
- **Non-free packages**: import `modules/non-free.nix` and extend `config.allowedUnfree` with package names.
- **Fastfetch**: `modules/fastfetch.nix` is imported in `profiles/base.nix` and provides the package, config file, and mail status command.

## flake.nix Conventions

- **mkDefaultSystem / mkLaptopSystem / mkServerSystem**: all machines are defined via these helpers. Do not call `nixpkgs.lib.nixosSystem` directly.
- **specialArgs**: injected into all machines via `mkDefaultSystem`. Keep minimal.
- **modules**: base modules (`sops-nix`, `home-manager`) are in `mkDefaultSystem`. Machine-specific modules are in each `configuration.nix`.
- **nixosConfigurations**: grouped as `# START SERVERS.` / `# START LAPTOPS.` / `# END ...`.

## Machine Config Conventions

- **configuration.nix**: imports `./hardware.nix`, `./../../profiles/<profile>.nix`, and module files from `modules/`.
- **Relative imports**: use `./../../modules/...` from within `machines/<host>/`.
- **gitSecrets**: available via `specialArgs` as `gitSecrets.<field>`. Do not duplicate secret values.
- **sopsSecrets**: path to `secrets/variables.yaml`, passed as `specialArgs`.
- **hostname**: always set `networking.hostName`.
- **stateVersion**: always set `system.stateVersion`.

## Secrets

- **sops-nix**: manages passwords and API keys. Declare secrets with `sops.secrets.<name> = { };` in the module/machine that needs them. Access via `config.sops.secrets.<name>.path`.
- **git-crypt**: hides non-sensitive data (IPs, domain names) from public git. The `secrets/` folder is git-crypt encrypted. CI uses `git-crypt unlock /etc/nixos/git-crypt-key`.
- **Never commit secrets in plaintext**. SOPS-encrypted files and git-crypt are the only allowed mechanisms.

## CI

- **quality-assurance.yml**: lint-only workflow. Runs `statix` and `nixfmt --check`. Triggers on all pushes and PRs.
- **build.yml**: build workflow. Runs on self-hosted runner. Has `validate` job (`nix flake check` + `nix flake archive`) and `build` job (matrix of all 10 machines).
- **Experimental features**: CI enables `nix-command flakes` via `extra_nix_config`.
- **Tools**: CI uses `nix run github:NixOS/nixpkgs#<tool>` to avoid flake resolution conflicts with the repo's own `flake.nix`.

## Pre-commit Hooks

- Config: `.pre-commit-config.yaml` with local hooks for `nixfmt` and `statix`.
- Install: `nix run github:NixOS/nixpkgs#pre-commit install`
- Run manually: `nix run github:NixOS/nixpkgs#pre-commit run --all-files`

## Formatting and Linting

- **nixfmt**: enforced. Run `nixfmt --check $(find . -name '*.nix' ...)` or `nix fmt` in CI.
- **statix**: enforced. Run `statix check .` locally before committing.
- **nix flake check**: Do not run locally, run only in CI.
- **cspell**: some terms are disabled inline with `# cspell:disable-line` (e.g., `cudnn`, `ddev`, `xdebug`). Do not add new cspell disables without need.

## Build and Deploy Commands

- **Rebuild current machine**: `sudo nixos-rebuild switch --flake .#$(hostname) --print-build-logs`
- **Short alias**: `osup` (defined in `modules/aliases.nix`)
- **nh switch**: `nh os switch .#nixosConfigurations.<hostname>` (requires `nh` package)
- **Short alias**: `nhup`
- **Flake update**: `nix flake update` or `flup` alias
- **Clean old generations**: `nh clean all --keep-since 5d --keep 3` or `nhcl` alias
- **Build specific machine**: `nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel`
- **Validate all configs**: `nix flake check`

## Naming Conventions

- **Files**: lowercase with hyphens (`email-server.nix`, `cuda-packages.nix`).
- **Modules**: `modules/<name>.nix`.
- **Machines**: `machines/<hostname>/` with `configuration.nix` as the entrypoint.
- **Options**: prefer nested options that match the NixOS module namespace (e.g., `services.phpfpm.defaultPoolSettings`, `cuda.allowedPackages`).
- **Machine config keys**: use machine hostname as the key in `networking.hosts` and ACME cert names.

## Anti-patterns

- Do not add `config = { ... }` wrappers to modules that don't declare `options`.
- Do not use `{ ... }:` for unused function args; use `_:`.
- Do not pass data through `specialArgs` that could be a module option.
- Do not leave large blocks of commented-out code. If it might be needed later, keep a minimal comment with a link to the original.
- Do not use absolute paths in configs. Use `config.sops.secrets.<name>.path` or `${pkgs.<package>}/...`.
