{
  config = {
    environment.shellAliases = {
      # Eza for well-known ls aliases, we still keep vanilla ls.
      ll = "eza -lh --icons --grid --group-directories-first";
      lg = "eza -lh --icons --grid --group-directories-first --git";
      la = "eza -lah --icons --grid --group-directories-first";
      lag = "eza -lah --icons --grid --group-directories-first --git";
    };
  };
}