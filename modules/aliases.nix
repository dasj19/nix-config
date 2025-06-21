{
  config = {
    environment.shellAliases = {
      # Eza for well-known ls aliases, we still keep vanilla ls.
      ll      = "eza -lh --icons --grid --group-directories-first";
      lg      = "eza -lh --icons --grid --group-directories-first --git";
      la      = "eza -lah --icons --grid --group-directories-first";
      lag     = "eza -lah --icons --grid --group-directories-first --git";
      # List files sorted by size ascending and descending.
      lt      = "du -sh * | sort -h";
      lr      = "du -sh * | sort -rh";
      # Quick(er) navigation.
      ".."    = "cd ..";
      h       = "cd ~";
      c       = "clear";
      # Networking. public ip, local ips, open ports, internal ports
      myip    = "curl http://icanhazip.com";
      lip     = "ip addr show | grep \"inet\\b\" | awk \'{print $2,$NF}\'";
      op      = "nmap localhost -p 0-65535";
      p       = "ping 1.1";
      ports   = "netstat -tulanp";
      # Create a dir and enter it. https://stackoverflow.com/a/55620350
      indir   = "function indir; mkdir $argv; cd $argv; end; indir";
    };
  };
}