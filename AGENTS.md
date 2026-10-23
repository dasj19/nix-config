# AGENTS.md

Coding conventions and project-specific guidance for this repository.
Disable spell-checking for this file: cspell:disable.

## Project Structure

```
.
├── flake.nix                 # Flake entrypoint, mk*System helpers, formatter, checks + apps outputs
├── flake.lock                # Pinned flake inputs
├── .github/workflows/
│   ├── autoupdate-flake.yml  # Daily flake update, pushed only if all machines build
│   ├── build.yml             # Flake check + build of every machine
│   └── quality-assurance.yml # Lint (statix, deadnix, nixfmt and sorted-lists flake checks)
├── .cspell/                  # Workspace spell-check dictionary
├── .vscode/                  # Editor settings (cspell dictionary path)
├── modules/                  # Shared NixOS modules, imported by machine configs
│   ├── acme.nix              # ACME/Cloudflare DNS + sops secrets
│   ├── ai.nix                # ollama, llama-cpp, AI CLI clients
│   ├── aliases.nix           # Fish shell abbreviations + aliases
│   ├── audio.nix             # PipeWire audio
│   ├── bluetooth.nix         # Bluetooth configuration
│   ├── browsers.nix          # Firefox, Chromium and other browser's preferences
│   ├── cuda-packages.nix     # Module option: config.cuda.allowedPackages
│   ├── desktop-common.nix    # Apps, keyring and MIME defaults shared by the desktop modules
│   ├── development.nix       # Shared web development stack (nodejs, mariadb, docker)
│   ├── email-server.nix      # Mailserver base config + rspamd
│   ├── fastfetch.nix         # Fast system information display
│   ├── fish.nix              # Fish shell + plugins
│   ├── folders.nix           # XDG user directories
│   ├── gnome.nix             # GNOME desktop + its home-manager modules (pick one desktop)
│   ├── hardware.nix          # Generic hardware detection + SMART + mail utils
│   ├── hyprland.nix          # Hyprland desktop + its home-manager modules (pick one desktop)
│   ├── keyboard.nix          # Keyboard layout
│   ├── locale.nix            # Internationalization properties
│   ├── nix.nix               # Nix daemon and nix-related config
│   ├── non-free.nix          # allowUnfreePredicate + allowedUnfree option
│   ├── openssh.nix           # OpenSSH server
│   ├── php-fpm.nix           # Module option: config.services.phpfpm.defaultPoolSettings
│   ├── primary-user.nix      # Module option: config.users.primaryUser (main user name)
│   ├── starship.nix          # Shell prompt configuration
│   ├── stylix.nix            # Uniform desktop styling
│   └── users.nix             # User accounts, sops passwords, sudo-rs
├── lib/
│   └── sorted-lists.nix      # Checks and sorts the imports and package lists, in pure nix
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
│   │   ├── gnome.nix         # GNOME settings
│   │   ├── hyprland.nix      # Hyprland window manager
│   │   ├── hyprlock.nix      # Hyprlock screen locker
│   │   ├── shellgpt.nix      # shell-gpt with ollama
│   │   ├── vscodium.nix      # VSCodium with extensions and settings
│   │   └── waybar.nix        # Waybar status bar
│   ├── pkgs/                 # Custom packages used by home-manager
│   │   └── libreoffice-impress-templates.nix
│   └── profiles/             # Per-profile home configs (base, laptop, server)
├── secrets/
│   ├── git-secrets.json      # Non-sensitive values (IPs, domains), git-crypt encrypted
│   └── variables.yaml        # Passwords and API keys, SOPS encrypted
├── pkgs/                     # Custom packages
│   ├── archivebox.nix        # Self-hosted internet archiving, with its missing python deps
│   ├── caddy-browse.nix      # Directory browsing plugin for Caddy
│   ├── clipvault.nix         # Clipboard history manager for Wayland
│   └── fish-colored-man.nix  # Local fish plugin, pending upstream submission
├── .pre-commit-config.yaml   # Pre-commit hooks: nixfmt, statix, deadnix and sorted-lists
├── .editorconfig             # Editor config: 2-space indent, LF, trim whitespace
├── statix.toml               # Statix linter configuration
├── .sops.yaml                # SOPS age keys and creation rules
├── .gitattributes            # Files encrypted by git-crypt
├── git-crypt-key             # git-crypt symmetric key, local only (git-ignored)
├── AGENTS.md                 # This file
├── CHANGELOG.md              # Dated log of major changes + TODO list
├── CONTRIBUTING.md           # Contributions are not accepted, issues are welcome
├── LICENSE
└── README.md
```

## NixOS Module Conventions

- **Header format**: first line is `# module-name: short description.`, second line is `# scope: ...`, from the third line on more details are presented.
- **Shorthand style**: use `_:` for unused args, not `{ ... }:` (statix requires `_`).
- **No `config = { ... }` wrapper** unless the module declares `options` and needs `config` to reference them (like `non-free.nix`, `cuda-packages.nix`, `php-fpm.nix`).
- **Ordering of elements**: order the elements in `imports` and `environment.systemPackages` alphabetically (case-insensitive). Each group under a comment or after a blank line is sorted on its own, and an entry's trailing comment moves with it. Enforced by the `sorted-lists` check, the list names live in `sortedLists` in `lib/sorted-lists.nix`.
- **Module options over specialArgs**: prefer declaring `options` in a module and importing it. Only use `specialArgs` for truly global values that cannot be module options (currently: `gitSecrets`, `sopsSecrets`).
- **ACME secrets**: always import `modules/acme.nix` on machines that use `security.acme` or `mailserver.x509.useACMEHost`. The module provides the sops secret declarations and Cloudflare DNS defaults.
- **PHP-FPM settings**: import `modules/php-fpm.nix` and merge with `// config.services.phpfpm.defaultPoolSettings`.
- **Non-free packages**: import `modules/non-free.nix` and extend `config.allowedUnfree` with package names.
- **User name**: never hardcode the main user name, use `config.users.primaryUser` (declared in `modules/primary-user.nix`, available on every machine). Home Manager derives `home.username` and `home.homeDirectory` from it.
- **Desktop environment**: a laptop imports exactly one desktop module (`modules/gnome.nix` or `modules/hyprland.nix`). The module imports `modules/desktop-common.nix` and adds its home-manager modules through `home-manager.sharedModules`, so `home/profiles/laptop.nix` stays desktop-agnostic.
- **Fastfetch**: `modules/fastfetch.nix` is imported in `profiles/base.nix` and provides the package, config file, and mail status command.

## flake.nix Conventions

- **mkDefaultSystem / mkLaptopSystem / mkServerSystem**: all machines are defined via these helpers. Do not call `nixpkgs.lib.nixosSystem` directly.
- **specialArgs**: injected into all machines via `mkDefaultSystem`. Keep minimal.
- **modules**: base modules (`sops-nix`, `home-manager`, `modules/primary-user.nix`) are in `mkDefaultSystem`. Machine-specific modules are in each `configuration.nix`.
- **nixosConfigurations**: grouped as `# START SERVERS.` / `# START LAPTOPS.` / `# END ...`.

## Machine Config Conventions

- **configuration.nix**: imports `./hardware.nix`, `./../../profiles/<profile>.nix`, and module files from `modules/`.
- **Relative imports**: use `./../../modules/...` from within `machines/<host>/`.
- **gitSecrets**: available via `specialArgs` as `gitSecrets.<field>`. Do not duplicate secret values.
- **sopsSecrets**: path to `secrets/variables.yaml`, passed as `specialArgs`.
- **hostname**: always set `networking.hostName`.
- **stateVersion**: always set `system.stateVersion`.
- **hostPlatform**: always set `nixpkgs.hostPlatform` in `hardware.nix`. Do not pass `system` to the `mk*System` helpers.

## Secrets

- **sops-nix**: manages passwords and API keys. Declare secrets with `sops.secrets.<name> = { };` in the module/machine that needs them. Access via `config.sops.secrets.<name>.path`.
- **git-crypt**: hides non-sensitive data (IPs, domain names) from public git. Only `secrets/git-secrets.json` is git-crypt encrypted (see `.gitattributes`); `secrets/variables.yaml` is SOPS encrypted. The key is never committed. CI uses `git-crypt unlock /etc/nixos/git-crypt-key`.
- **Never commit secrets in plaintext**. SOPS-encrypted files and git-crypt are the only allowed mechanisms.

## CI

- **quality-assurance.yml**: lint-only workflow. Builds the `statix`, `deadnix`, `nixfmt` and `sorted-lists` flake checks. Triggers on all pushes and PRs.
- **autoupdate-flake.yml**: daily `nix flake update` on the self-hosted runner. Builds every machine with the new lock, commits and pushes `flake.lock` only if all builds pass, then dispatches `build.yml`.
- **build.yml**: build workflow. Runs on self-hosted runner. Has `validate` job (`nix flake check` + `nix flake archive`) and `build` job (runs after `validate`, matrix of all machines listed from `nixosConfigurations`).
- **Experimental features**: CI enables `nix-command flakes` via `extra_nix_config`.
- **Tools**: linters come from the flake's `checks` output, so CI, pre-commit and local runs use the nixpkgs pinned in `flake.lock`.

## Pre-commit Hooks

- Config: `.pre-commit-config.yaml` with local hooks for `nixfmt`, `statix`, `deadnix` and `sorted-lists`.
- Install: `nix run github:NixOS/nixpkgs#pre-commit install`
- Run manually: `nix run github:NixOS/nixpkgs#pre-commit run --all-files`

## Formatting and Linting

- **nixfmt**: enforced. Run `nix fmt` to format all files, or `nix build .#checks.x86_64-linux.nixfmt` to only check them.
- **statix**: enforced. Run `nix build .#checks.x86_64-linux.statix` locally before committing.
- **deadnix**: enforced. Reports unused function arguments and let bindings. Run `nix build .#checks.x86_64-linux.deadnix`.
- **sorted-lists**: enforced. Run `nix build .#checks.x86_64-linux.sorted-lists` to check, or `nix run .#sort-lists` from the repository root to sort the lists in place.
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
