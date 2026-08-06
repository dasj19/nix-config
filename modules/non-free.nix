# https://discourse.nixos.org/t/use-nixpkgs-config-allowunfreepredicate-in-multiple-nix-file/36590
# https://codeberg.org/AndrewKvalesm/configuration/src/commit/11794e595144500a6c2be706e42ed698b1788bb8/packages/nixpkgs-issue-55674.nix

{
  config,
  lib,
  ...
}:

let
  inherit (builtins) elem;
  inherit (lib) getName mkOption;
  inherit (lib.types) listOf str;
in

{
  options.allowedUnfree = mkOption {
    type = listOf str;
    default = [ ];
  };

  config = {
    nixpkgs.config.allowUnfreePredicate = p: elem (getName p) config.allowedUnfree;
    nixpkgs.config.allowUnfree = false;
  };
}
