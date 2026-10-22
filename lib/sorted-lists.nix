# sorted-lists: check and sort the imports and package lists of nix files.
# scope: flake checks and apps
# Inside the lists named in sortedLists, every run of consecutive simple entries
# (one package attribute or relative path per line, optionally followed by a `# comment`)
# must be sorted case-insensitively. Comment lines, blank lines and any other line
# end a run and keep their place, so commented groups are sorted on their own.

{ lib }:

let
  inherit (builtins)
    filter
    foldl'
    head
    length
    match
    readFile
    split
    ;
  inherit (lib)
    concatStringsSep
    escapeRegex
    findFirst
    hasSuffix
    imap1
    optional
    removePrefix
    sort
    splitString
    toLower
    zipListsWith
    ;

  # List attributes that must be kept sorted, add more names here.
  sortedLists = [
    "environment.systemPackages"
    "imports"
  ];

  # A line that opens one of the sorted lists, like `imports = [`.
  startRegex = ''[[:space:]]*(${concatStringsSep "|" (map escapeRegex sortedLists)})[[:space:]]*=.*\[[[:space:]]*'';
  # A package attribute path or a relative path to a nix file, with an optional comment.
  simpleRegex = "[[:space:]]*([A-Za-z_.][A-Za-z0-9_./'-]*)([[:space:]]*#.*)?[[:space:]]*";

  # Number of times the character `c` occurs in `text`.
  count = c: text: (length (split (escapeRegex c) text) - 1) / 2;

  isSimple = text: match simpleRegex text != null && count "[" text == 0 && count "]" text == 0;

  key = text: toLower (head (match simpleRegex text));

  # Sorts the pending run of entries and reports its first misplaced entry.
  flush =
    state:
    let
      ordered = sort (a: b: key a.text < key b.text) state.run;
      mismatch = findFirst (pair: pair.found.text != pair.expected.text) null (
        zipListsWith (found: expected: { inherit found expected; }) state.run ordered
      );
    in
    state
    // {
      out = state.out ++ map (entry: entry.text) ordered;
      run = [ ];
      problems =
        state.problems
        ++ optional (mismatch != null) {
          line = mismatch.found.number;
          message = "expected '${key mismatch.expected.text}' here, found '${key mismatch.found.text}'";
        };
    };

  step =
    state: line:
    if !state.inside then
      state
      // {
        out = state.out ++ [ line.text ];
        inside = match startRegex line.text != null;
        depth = 1;
      }
    else
      let
        depth = state.depth + count "[" line.text - count "]" line.text;
        flushed = flush state;
      in
      if depth <= 0 then
        flushed
        // {
          out = flushed.out ++ [ line.text ];
          inside = false;
          inherit depth;
        }
      # Only entries at the list's own nesting level are sorted.
      else if depth == 1 && isSimple line.text then
        state
        // {
          run = state.run ++ [ line ];
          inherit depth;
        }
      else
        flushed
        // {
          out = flushed.out ++ [ line.text ];
          inherit depth;
        };

  # Returns the sorted text of one file and its problems.
  sortText =
    text:
    let
      lines = imap1 (number: text: { inherit number text; }) (splitString "\n" text);
      result = flush (
        foldl' step {
          out = [ ];
          run = [ ];
          problems = [ ];
          inside = false;
          depth = 0;
        } lines
      );
    in
    {
      sorted = concatStringsSep "\n" result.out;
      inherit (result) problems;
    };
in
{
  inherit sortedLists sortText;

  # Every nix file below `root` with unsorted lists, as { path, sorted, problems }.
  unsortedFiles =
    root:
    filter (file: file.problems != [ ]) (
      map (
        path:
        sortText (readFile path)
        // {
          path = removePrefix "${toString root}/" (toString path);
        }
      ) (filter (path: hasSuffix ".nix" (toString path)) (lib.filesystem.listFilesRecursive root))
    );
}
