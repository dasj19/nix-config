# clipvault: Clipboard history manager for Wayland, inspired by cliphist.
# scope: all machines with hyprland

{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "clipvault";
  version = "1.3.0";

  arch =
    if stdenv.hostPlatform.isx86_64 then
      "x86_64"
    else if stdenv.hostPlatform.isAarch64 then
      "aarch64"
    else
      abort "Unsupported architecture";

  src = fetchFromGitHub {
    owner = "Rolv-Apneseth";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-3KXb+IWthxWm6WsI/EiXOatDZ0Z76fMGL96ZNeRrYSQ=";
  };

  cargoHash = "sha256-kRTBUf2GObUqsDB9ewY42I6vQQQPS6wbmeXuj3EVh1g=";

  # 16 tests fail in NixOS.
  doCheck = false;

  meta = with lib; {
    description = "Clipboard history manager for Wayland, inspired by cliphist";
    homepage = "https://github.com/rolv-apneseth/clipvault";
    license = licenses.agpl3Only;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
