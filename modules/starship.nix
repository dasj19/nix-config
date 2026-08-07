# starship: cross-shell prompt configuration.
# scope: all machines
#
# Provides prompt appearance, git status symbols, and disabled modules.

{
  # Cross-shell prompt.
  programs.starship.enable = true;

  # Starship configuration.
  programs.starship.settings = {
    # General prompt settings.
    add_newline = false;
    line_break = {
      disabled = true;
    };
    sudo = {
      disabled = true;
    };

    # Prompt segments.
    username = {
      show_always = true;
      format = "[$user]($style)@";
    };
    hostname = {
      ssh_only = false;
      format = "[$ssh_symbol$hostname]($style) :";
    };
    directory = {
      format = "[ $path ]($style)";
      truncation_length = 3;
      truncation_symbol = "…/";
    };
    time = {
      disabled = false;
    };
    status = {
      disabled = false;
      map_symbol = true;
    };

    # Git status symbols.
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

    # Disabled language modules.
    php = {
      disabled = true;
    };
    nodejs = {
      disabled = true;
    };

    # Prompt symbol.
    character = {
      error_symbol = "✗";
      success_symbol = "❯";
    };

    # Command duration.
    cmd_duration = {
      min_time = 2000;
      format = "took [$duration]($style) ";
    };

    # Battery indicator (laptops only).
    battery = {
      disabled = false;
      full_symbol = "🔋";
      charging_symbol = "⚡";
      discharging_symbol = "💀";
    };

    # Container runtime.
    container = {
      disabled = false;
      style = "bold red";
    };

    # Background jobs.
    jobs = {
      disabled = false;
    };
  };
}
