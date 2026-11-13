# update-actions: move the pinned GitHub Actions to the newest release of their major version.
# scope: flake apps, run by .github/workflows/update-actions.yml
# Every action in .github/workflows is pinned as `uses: owner/repo@<commit> # <version>`.
# A newer major version can break the workflows, so it is only reported, never applied.
# Uses $GITHUB_TOKEN for the GitHub API when it is set, to avoid the anonymous rate limit.

{ pkgs }:

let
  # The newest published release tag, of the major version in $m when it is not empty.
  newestRelease = pkgs.writeText "newest-release.jq" ''
    [.[] | select((.draft or .prerelease) | not) | .tag_name
      | select($m == "" or . == $m or ltrimstr($m + ".") != .)]
    | first // empty
  '';
in
pkgs.writeShellApplication {
  name = "update-actions";
  runtimeInputs = with pkgs; [
    coreutils
    curl
    gnugrep
    gnused
    jq
  ];
  text = ''
    if [ ! -d .github/workflows ]; then
      echo "Run this from the repository root." >&2
      exit 1
    fi

    api() {
      local auth=()
      if [ -n "''${GITHUB_TOKEN:-}" ]; then
        auth=(-H "Authorization: Bearer $GITHUB_TOKEN")
      fi
      curl -fsSL "''${auth[@]}" -H "Accept: application/vnd.github+json" "https://api.github.com/$1"
    }

    pins=$(grep -ohE 'uses: [A-Za-z0-9_.-]+/[A-Za-z0-9_./-]+@[0-9a-f]{40} # v[^ ]+' .github/workflows/*.yml | sort -u)

    while read -r _ ref _ version; do
      action=''${ref%@*}
      sha=''${ref#*@}
      repo=$(cut -d/ -f1,2 <<< "$action")
      major=''${version%%.*}

      releases=$(api "repos/$repo/releases?per_page=100")
      newest=$(jq -r --arg m "" -f ${newestRelease} <<< "$releases")
      same_major=$(jq -r --arg m "$major" -f ${newestRelease} <<< "$releases")

      if [ -z "$same_major" ]; then
        echo "$action: no $major release found, left at $version."
      else
        new_sha=$(api "repos/$repo/commits/$same_major" | jq -r .sha)
        if [ "$new_sha" = "$sha" ]; then
          echo "$action: up to date at $version."
        else
          sed -i "s|$action@$sha # $version|$action@$new_sha # $same_major|g" .github/workflows/*.yml
          echo "$action: updated $version -> $same_major."
        fi
      fi

      if [ -n "$newest" ] && [ "''${newest%%.*}" != "$major" ]; then
        echo "$action: new major version $newest available, update it by hand."
      fi
    done <<< "$pins"
  '';
}
