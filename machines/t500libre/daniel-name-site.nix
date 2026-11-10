# t500libre: static personal page served on the daniel name domain.
# scope: machine
#
# The source is the daniel-name-site flake input (flake = false), applied
# through an overlay in flake.nix. GitHub's source archive honours the
# repository's export-ignore rules, so only served files and the licences
# are fetched. Text files get Brotli, zstd and
# gzip sidecars for Caddy's file_server precompressed option. Every file gets a
# ".etag" sidecar with a content hash, read by file_server etag_file_extensions,
# because all store files share mtime 1 and Caddy's default ETag (mtime + size)
# would not change on same-size edits.

{
  brotli,
  src,
  stdenvNoCC,
  zstd,
}:

stdenvNoCC.mkDerivation {
  pname = "daniel-name-site";
  # e.g. 0-unstable-2026-11-10, from the input's last commit date.
  version =
    let
      date = src.lastModifiedDate;
    in
    "0-unstable-${builtins.substring 0 4 date}-${builtins.substring 4 2 date}-${builtins.substring 6 2 date}";

  inherit src;

  nativeBuildInputs = [
    brotli
    zstd
  ];

  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    cp -r . $out
    cd $out

    find . -type f \( -name '*.html' -o -name '*.css' -o -name '*.js' -o -name '*.svg' \
      -o -name '*.ico' -o -name '*.json' -o -name '*.xml' -o -name '*.txt' -o -name '*.webmanifest' \) \
      -exec brotli -k -q 11 {} \; -exec zstd -qk -19 {} \; -exec gzip -kn -9 {} \;

    # Strong ETags from the content, quoted as RFC 9110 requires.
    find . -type f ! -name '*.etag' -print0 | while IFS= read -r -d "" f; do
      printf '"%s"' "$(sha256sum "$f" | cut -c1-32)" > "$f.etag"
    done

    runHook postInstall
  '';
}
