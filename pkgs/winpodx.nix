# winpodx: Windows apps on the Linux desktop, through FreeRDP RemoteApp and dockur/windows in podman.
# scope: t14
#
# Mirrors the package from the upstream flake.nix, pinned to a release tag.
# Run `winpodx setup` once after installing, `winpodx doctor` reports what is missing.

{
  lib,
  python3Packages,
  fetchFromGitHub,
  freerdp,
  iproute2,
  libnotify,
  podman,
  podman-compose,
}:

python3Packages.buildPythonApplication rec {
  pname = "winpodx";
  version = "0.12.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "kernalix7";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-Dty1b2bROyH4hvvQ5HUQcOYLNMDfUh8Jk4kCipOt4X4=";
  };

  build-system = [ python3Packages.hatchling ];

  dependencies = with python3Packages; [
    cairosvg # reverse-open: SVG icons to PNG.
    docker
    pillow # reverse-open: icons to ICO.
    pyside6
    pyxdg # reverse-open: icon theme lookup.
  ];

  # 8 of the 4700 tests fail in the sandbox (release packaging scripts, Qt widget geometry),
  # then pytest segfaults on the Qt teardown. The suite also takes ~14 minutes.
  doCheck = false;

  # The data, config and guest scripts ship as the wheel's shared-data, in share/winpodx.
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      freerdp
      iproute2
      libnotify
      podman
      podman-compose
    ])
    "--set"
    "WINPODX_BUNDLE_DIR"
    "${placeholder "out"}/share/winpodx"
  ];

  pythonImportsCheck = [ "winpodx" ];

  meta = {
    description = "Windows app integration for the Linux desktop (FreeRDP RemoteApp + dockur/windows)";
    homepage = "https://github.com/kernalix7/winpodx";
    license = with lib.licenses; [
      asl20
      mit
      ofl
    ];
    mainProgram = "winpodx";
    platforms = lib.platforms.linux;
  };
}
