# duckduckgo-chat-cli: terminal client for DuckDuckGo's AI chat (Duck.ai).
# scope: t14
#
# Duck.ai proof generation needs a Chromium-based browser on PATH. Chromium is
# appended to PATH as a fallback, so a browser already on PATH still wins.
# Built from the prepare-for-nix-packaging branch of the dasj19 fork, whose noupdatecheck build tag
# compiles out upstream's update checks and self-update, nix updates this package.
# duckchat relaunches itself from PATH, so its desktop entry survives upgrades and garbage collection.

{
  buildGo127Module,
  chromium,
  fetchFromGitHub,
  lib,
  makeWrapper,
  versionCheckHook,
}:

buildGo127Module (finalAttrs: {
  pname = "duckduckgo-chat-cli";
  version = "1.9.9-unstable-2026-11-04";

  src = fetchFromGitHub {
    owner = "dasj19";
    repo = "duckduckgo-chat-cli";
    rev = "9fc9e1a1e43c90df75ab2a83a20127af5a8e76e3"; # Branch prepare-for-nix-packaging.
    hash = "sha256-KWLjGz8QCgGQ4EKJ2h3D422+Yw2hq+t/GOYL+vOoKCc=";
  };

  vendorHash = "sha256-gawENoHpOgXXnpEXMzXQ3UnGQhq7kgTPb65F5vjwA+0=";

  subPackages = [ "cmd/duckchat" ];

  # Compiles out the GitHub update checks at startup and in /version, and the /update self-update.
  tags = [ "noupdatecheck" ];

  postPatch = ''
    # The noupdatecheck tag leaves /update in place, reporting that updates are disabled. Remove it
    # from the command registry, after its examples are added, so it is left out of the help and
    # the completions.
    substituteInPlace internal/command/command.go \
      --replace-fail '	return registry' '	delete(registry.Commands, "/update"); return registry'

    # duckchat relaunches itself (tray service, tray actions, the Wayland desktop entry written to
    # ~/.local/share/applications) from os.Executable(), the unwrapped binary under its versioned
    # store path. Look it up on PATH instead, so it goes through the wrapper and the desktop entry
    # keeps a generic path like /run/current-system/sw/bin/duckchat that survives upgrades.
    for file in cmd/duckchat/main.go internal/tray/shortcut_portal_linux.go; do
      substituteInPlace "$file" \
        --replace-fail 'import (' 'import (
    	"os/exec"' \
        --replace-fail 'os.Executable()' 'exec.LookPath("${finalAttrs.meta.mainProgram}")'
    done
  '';

  ldflags = [
    # Leaves out the symbol table and the DWARF debug information (-s implies -w since Go 1.22).
    "-s"
    # Version values set at compile time, the same way as upstream's scripts/build.sh.
    "-X main.Version=v${finalAttrs.version}"
    "-X duckduckgo-chat-cli/internal/version.Current=${finalAttrs.version}"
  ];

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/duckchat --suffix PATH : ${lib.makeBinPath [ chromium ]}
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "CLI client for DuckDuckGo's AI chat (Duck.ai)";
    homepage = "https://github.com/benoitpetit/duckduckgo-chat-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dasj19 ];
    mainProgram = "duckchat";
    # The tray, global shortcuts and voice window code is Linux-specific.
    platforms = lib.platforms.linux;
  };
})
