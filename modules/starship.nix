# starship: cross-shell prompt configuration.

{
  # Cross-shell prompt.
  programs.starship.enable = true;
  # Starship configuration.
  programs.starship.settings = {
    # No new line before the prompt.
    add_newline = false;
    # Module configuration.
    line_break = {
      disabled = true;
    };
    # Disable auto running commands that require sudo,
    # spamming the logs with failed auth requests.
    sudo = {
      disabled = true;
    };
    username = {
      show_always = true;
      format = "[$user]($style)@";
    };
    hostname = {
      ssh_only = false;
      format = "[$ssh_symbol$hostname]($style)  ";
    };
    directory = {
      format = "[ $path ]($style)";
      truncation_length = 3;
      truncation_symbol = "…/";
    };
    directory.substitutions = {
      documents = "󰈙 ";
      downloads = " ";
      media = "🎞️ ";
      music = "󰎄 ";
      photos = " ";
      video = "󰽜 ";
      workspace = "󱗿 ";
      "~" = " ";
    };
    time = {
      disabled = false;
    };
    status = {
      disabled = false;
      map_symbol = true;
    };
    git_status = {
      disabled = false;
      conflicted = "🏳";
      ahead = "🏎💨";
      behind = "😰";
      diverged = "😵";
      up_to_date = "✓";
      untracked = "🤷";
      stashed = "📦";
      modified = "📝";
      staged = "[++\($count\)](green)";
      renamed = "👅";
      deleted = "🗑";
    };
    php = {
      disabled = true;
    };
    nodejs = {
      disabled = true;
    };
  };
}
