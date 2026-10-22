{
  description = "The dasj-lab flake";

  # Tracking 'nixpkgs-unstable' branch which is usually a couple days behind master.
  # 'nixpkgs-unstable' goes through less tests than 'nixos-unstable'.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  # Assures compatibility with older version of nix before the version 2.4.
  inputs.flake-compat.url = "github:NixOS/flake-compat";

  # Nix module system for flakes.
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  # NixOS artwork, used for wallpapers. # cspell:disable-next-line
  inputs.nixos-artwork.url = "github:gytis-ivaskevicius/high-quality-nix-content";
  inputs.nixos-artwork.inputs.nixpkgs.follows = "nixpkgs";

  # Security tool to encrypt-decrypt secrets.
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";

  # Project that seeks to apply uniform styles for NixOS systems.
  inputs.stylix.url = "github:nix-community/stylix";
  inputs.stylix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.stylix.inputs.systems.follows = "systems";
  inputs.stylix.inputs.flake-parts.follows = "flake-parts";

  # Hardware configurations for NixOS.
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";
  inputs.nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

  # A mail server stack.
  inputs.nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
  inputs.nixos-mailserver.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixos-mailserver.inputs.flake-compat.follows = "flake-compat";

  # Manage user environment with nix.
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  # Collection of new file templates for the user environment.
  inputs.awesome-linux-templates.url = "github:dasj19/awesome-linux-templates";
  inputs.awesome-linux-templates.flake = false;

  # Latest ulauncher.
  inputs.ulauncher.url = "github:Ulauncher/Ulauncher";
  inputs.ulauncher.inputs.nixpkgs.follows = "nixpkgs";
  inputs.ulauncher.inputs.flake-parts.follows = "flake-parts";

  inputs.systems.url = "github:nix-systems/x86_64-linux";

  outputs =
    {
      self,
      nixpkgs,
      awesome-linux-templates,
      nixos-artwork,
      nixos-hardware,
      sops-nix,
      nixos-mailserver,
      stylix,
      home-manager,
      ulauncher,
      systems,
      ...
    }:
    let
      gitSecrets = builtins.fromJSON (builtins.readFile "${self}/secrets/git-secrets.json");
      sopsSecrets = ./secrets/variables.yaml;

      # A function to define an output for every supported system.
      forAllSystems =
        f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});

      # Nix files whose imports or package lists are not sorted, see lib/sorted-lists.nix.
      unsortedFiles = (import ./lib/sorted-lists.nix { inherit (nixpkgs) lib; }).unsortedFiles self;
      unsortedReport = nixpkgs.lib.concatMapStrings (
        file:
        nixpkgs.lib.concatMapStrings (
          problem: "${file.path}:${toString problem.line}: list not sorted, ${problem.message}\n"
        ) file.problems
      ) unsortedFiles;

      # A function to create a check that runs a linter over the repository.
      mkLintCheck =
        pkgs: name: tool: command:
        pkgs.runCommand "check-${name}" { nativeBuildInputs = [ tool ]; } ''
          cd ${self}
          ${command}
          touch $out
        '';

      # A function to create a default system configuration that can be extended.
      mkDefaultSystem =
        cfg:
        let
          defaults = {
            # Common special arguments for all systems.
            specialArgs = {
              inherit gitSecrets;
              inherit sopsSecrets;
            };
            # Common modules for all systems.
            modules = [
              sops-nix.nixosModules.sops
              home-manager.nixosModules.home-manager
            ];
          };
          # Merge defaults with custom configuration.
          config =
            defaults
            // cfg
            // {
              specialArgs = defaults.specialArgs // (cfg.specialArgs or { });
              modules = defaults.modules ++ (cfg.modules or [ ]);
            };
        in
        nixpkgs.lib.nixosSystem config;

      # A function to create laptop systems with common configuration.
      mkLaptopSystem =
        cfg:
        mkDefaultSystem {
          specialArgs = {
            inherit nixos-artwork;
            inherit awesome-linux-templates;
          };
          modules = [
            stylix.nixosModules.stylix

            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.daniel = import ./home/profiles/laptop.nix;
              home-manager.extraSpecialArgs = {
                inherit awesome-linux-templates;
                inherit gitSecrets;
              };
            }

            (
              { pkgs, ... }:
              {
                environment.systemPackages = [
                  ulauncher.packages.${pkgs.stdenv.hostPlatform.system}.ulauncher6
                ];
              }
            )
          ]
          ++ (cfg.modules or [ ]);
        };

      # A function to create server systems with common configuration.
      mkServerSystem =
        cfg:
        mkDefaultSystem {
          modules = [
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.daniel = import ./home/profiles/server.nix;
              home-manager.extraSpecialArgs = {
                inherit gitSecrets;
              };
            }
          ]
          ++ (cfg.modules or [ ]);
        };
    in
    {
      # Formats all nix files with `nix fmt`.
      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);

      # Linters, run by `nix flake check` and by the QA workflow.
      checks = forAllSystems (pkgs: {
        nixfmt = mkLintCheck pkgs "nixfmt" pkgs.nixfmt "find . -name '*.nix' -exec nixfmt --check {} +";
        statix = mkLintCheck pkgs "statix" pkgs.statix "statix check .";
        deadnix = mkLintCheck pkgs "deadnix" pkgs.deadnix "deadnix --fail .";
        sorted-lists = pkgs.runCommand "check-sorted-lists" { inherit unsortedReport; } ''
          if [ -n "$unsortedReport" ]; then
            printf '%s' "$unsortedReport" >&2
            echo "Fix them with: nix run .#sort-lists" >&2
            exit 1
          fi
          touch $out
        '';
      });

      # Sorts the lists checked by `sorted-lists` in place, run it from the repository root.
      apps = forAllSystems (pkgs: {
        sort-lists = {
          type = "app";
          meta.description = "Sort the imports and package lists of all nix files";
          program = toString (
            pkgs.writeShellScript "sort-lists" ''
              set -eu
              if [ ! -f flake.nix ]; then
                echo "Run this from the repository root." >&2
                exit 1
              fi
              ${nixpkgs.lib.concatMapStrings (file: ''
                cat ${pkgs.writeText "sorted.nix" file.sorted} > ${nixpkgs.lib.escapeShellArg file.path}
                echo ${nixpkgs.lib.escapeShellArg "${file.path}: sorted"}
              '') unsortedFiles}
            ''
          );
        };
      });

      # START SERVERS.
      nixosConfigurations.contabo2 = mkServerSystem {
        modules = [
          ./machines/contabo2/configuration.nix
          nixos-mailserver.nixosModules.default
        ];
      };
      nixosConfigurations.cm4-nas = mkServerSystem {
        modules = [
          ./machines/cm4-nas/configuration.nix
          # @todo Include hardware support for the compute module 4.
        ];
      };
      nixosConfigurations.ideapad100 = mkServerSystem {
        modules = [
          ./machines/ideapad100/configuration.nix
        ];
      };
      nixosConfigurations.linodenix1 = mkServerSystem {
        modules = [
          ./machines/linodenix1/configuration.nix
          nixos-mailserver.nixosModules.default
        ];
      };
      nixosConfigurations.linodenix2 = mkServerSystem {
        modules = [
          ./machines/linodenix2/configuration.nix
          nixos-mailserver.nixosModules.default
        ];
      };
      nixosConfigurations.rpi4-tv = mkServerSystem {
        modules = [
          ./machines/rpi4-tv/configuration.nix
          nixos-hardware.nixosModules.raspberry-pi-4
        ];
      };
      nixosConfigurations.t500libre = mkServerSystem {
        modules = [
          ./machines/t500libre/configuration.nix
          nixos-hardware.nixosModules.lenovo-thinkpad
          nixos-mailserver.nixosModules.default
        ];
      };
      # END SERVERS.
      # START LAPTOPS.
      nixosConfigurations.t14 = mkLaptopSystem {
        modules = [
          ./machines/t14/configuration.nix
          nixos-hardware.nixosModules.lenovo-thinkpad-t14-intel-gen1-nvidia
        ];
      };
      nixosConfigurations.tuxedo-xa15 = mkLaptopSystem {
        modules = [
          ./machines/tuxedo-xa15/configuration.nix
        ];
      };
      # END LAPTOPS.
    };
}
