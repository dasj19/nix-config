{
  fetchurl,
  lib,
  stdenv,
  ...
}:

stdenv.mkDerivation rec {
  pname = "libreoffice-impress-templates";
  version = "2.2";

  src = fetchurl {
    url = "https://github.com/dohliam/libreoffice-impress-templates/releases/download/v${version}/libreoffice-impress-templates-all_${version}-1.deb";
    hash = "sha256-InTrsTG8jCq3L5ekqA4qv8aepS4eQzcaFkfStkJt2OA=";
  };

  unpackPhase = ''
    runHook preUnpack

    mkdir -p $TMP/libreoffice-impress-templates
    cp $src $TMP/libreoffice-impress-templates.deb
    ar vx libreoffice-impress-templates.deb
    tar --no-overwrite-dir -xvf data.tar.xz -C libreoffice-impress-templates

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    cp -R libreoffice-impress-templates/usr/lib/libreoffice/share/template/common/presnt/ $out/

    runHook postInstall
  '';

  meta = {
    description = "Collection of freely available LibreOffice Templates";
    homepage = "https://github.com/dohliam/libreoffice-impress-templates";
    license = lib.licenses.mit;
  };
}
