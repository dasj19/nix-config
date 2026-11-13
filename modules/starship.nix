# starship: cross-shell prompt configuration.
# scope: all machines
#
# Minimal single-line prompt: segments only appear when they carry information
# (user@host over ssh, git state, slow commands, background jobs, low battery).

{
  # Cross-shell prompt.
  programs.starship.enable = true;

  # Starship configuration.
  programs.starship.settings = {
    # General prompt settings, an explicit format keeps language modules out.
    add_newline = false;
    format = "$username$hostname$directory$git_branch$git_state$git_status$nix_shell$container$cmd_duration$jobs$battery$character";

    # Identity, user@host always shown.
    username = {
      show_always = true;
      format = "[$user]($style)";
    };
    hostname = {
      ssh_only = false;
      format = "@[$hostname]($style)";
    };

    # Working directory.
    directory = {
      format = " [$path]($style)[$read_only]($read_only_style) ";
      style = "bold cyan";
      read_only = " ro";
      truncation_length = 3;
      truncation_symbol = "…/";
    };

    # Git branch, state and status.
    git_branch = {
      format = "[$branch]($style) ";
      style = "purple";
    };
    git_state = {
      format = "[$state( $progress_current/$progress_total)]($style) ";
    };
    git_status = {
      format = "([$all_status$ahead_behind]($style) )";
      style = "yellow";
      conflicted = "=";
      ahead = "⇡\${count}";
      behind = "⇣\${count}";
      diverged = "⇡\${ahead_count}⇣\${behind_count}";
      untracked = "?";
      stashed = "≡";
      modified = "!";
      staged = "+";
      renamed = "»";
      deleted = "✘";
    };

    # Environments.
    nix_shell = {
      format = "[$symbol]($style) ";
      symbol = "❄";
    };
    container = {
      format = "[⬢ $name]($style) ";
      style = "bold red";
    };

    # Command duration.
    cmd_duration = {
      min_time = 2000;
      format = "[$duration]($style) ";
      style = "yellow";
    };

    # Background jobs.
    jobs = {
      format = "[$symbol$number]($style) ";
      symbol = "✦";
    };

    # Battery indicator, only when low (laptops only).
    battery = {
      format = "[$symbol$percentage]($style) ";
      full_symbol = "";
      charging_symbol = "⚡";
      discharging_symbol = "↓";
      display = [
        {
          threshold = 20;
          style = "bold red";
        }
      ];
    };

    # Prompt symbol, red after a failed command.
    character = {
      success_symbol = "[❯](bold green)";
      error_symbol = "[❯](bold red)";
    };
  };
}
