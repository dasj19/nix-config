# primary-user: name of the main user account.
# scope: all machines
# Declared as a module option so other modules can reference
# `config.users.primaryUser` instead of hardcoding the user name.

{ lib, ... }:

{
  options.users.primaryUser = lib.mkOption {
    type = lib.types.str;
    default = "daniel";
    description = "Name of the main user account, used for users, home-manager, auto-login and nix trust.";
  };
}
