{
  lib,
  stdenv,
  fetchFromGitHub,
  imagemagick,
  gettext,
  nss,
  pidgin,
  qrencode,
  json-glib,
}:

stdenv.mkDerivation {
  pname = "purple-discord";
  version = "unstable-2026-03-29";

  src = fetchFromGitHub {
    owner = "EionRobb";
    repo = "purple-discord";
    rev = "daily-2026-03-29";
    hash = "sha256-F8sHEDe8gznQKxpzlzpoc2Tkcr0EqKTO7jxIW4IR81U=";
  };

  nativeBuildInputs = [
    imagemagick
    gettext
  ];
  buildInputs = [
    nss
    pidgin
    qrencode
    json-glib
  ];

  env = {
    PKG_CONFIG_PURPLE_PLUGINDIR = "${placeholder "out"}/lib/purple-2";
    PKG_CONFIG_PURPLE_DATADIR = "${placeholder "out"}/share";
  };

  meta = {
    homepage = "https://github.com/EionRobb/purple-discord";
    description = "Discord plugin for Pidgin";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ sna ];
  };
}
