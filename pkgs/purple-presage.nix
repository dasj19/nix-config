{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  cargo,
  jq,
  libsysprof-capture,
  libdeflate,
  libwebp,
  lerc,
  mount,
  qrencode,
  openssl,
  pidgin,
  pcre2,
  pkgs,
  xz,
  zstd,
}:

stdenv.mkDerivation {
  pname = "purple-presage";
  version = "unstable-2026-04-12";

  src = fetchFromGitHub {
    owner = "hoehermann";
    repo = "purple-presage";
    rev = "nightly-20260412-7bbaf1a";
    hash = "sha256-pPjbvom8T0XHQASopwNIg9iYJEvZ6hTHTb19tI13D0k=";
  };

  passthru = {
    sources = {
      # rev from source/bindings/CMakeLists.txt
      corrosion = fetchFromGitHub {
        owner = "corrosion-rs";
        repo = "corrosion";
        rev = "v0.5.2";
        hash = "sha256-sO2U0llrDOWYYjnfoRZE+/ofg3kb+ajFmqvaweRvT7c=";
      };
    };
  };

  nativeBuildInputs = [

  ];
  buildInputs = [
    cargo
    cmake
    jq
    libsysprof-capture
    libdeflate
    libwebp
    mount
    xz # has liblzma
    lerc
    openssl
    pidgin
    qrencode
    pcre2
    zstd
  ];

  patchPhase = ''
    runHook prePatch

    substituteInPlace CMakeLists.txt \
      --replace-fail "find_package(Purple REQUIRED)" "#find_package(Purple REQUIRED)" \
      --replace-fail "FetchContent_MakeAvailable(Corrosion)" "#FetchContent_MakeAvailable(Corrosion)" \
      --replace-fail "corrosion_import_crate" "#corrosion_import_crate" \
      --replace-fail "corrosion_set_env_vars" "#corrosion_set_env_vars" \
      --replace-fail "corrosion_add_target_rustflags" "#corrosion_add_target_rustflags"
    runHook postPatch
  '';
  env = {
    PKG_CONFIG_PURPLE_PLUGINDIR = "${placeholder "out"}/lib/purple-2";
    PKG_CONFIG_PURPLE_DATADIR = "${placeholder "out"}/share";
  };

  meta = {
    homepage = "https://github.com/hoehermann/purple-pressage";
    description = "Signal plugin for Pidgin";
    #license = lib.licenses.gpl3;
    #platforms = lib.platforms.linux;
    #maintainers = with lib.maintainers; [ sna ];
  };
}
