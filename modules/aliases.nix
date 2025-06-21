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
      # Change file permissions.
      cha     = "chmod a+rwx";
      chr     = "chmod a+r";
      chx     = "chmod a+x";
      chw     = "chmod a+w";
      # Assign ownership to current user, current group.
      cho     = "chown $(whoami):$(id -gn $(whoami))";
      # Git shortcuts.
      gs      = "git status";
      ga      = "git add";
      gc      = "git commit";
      gp      = "git push";
      gd      = "git diff";
      gl      = "git log";
      g1      = "git log --oneline";
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
      # Nix specific. OS update.
      osup    = "sudo nixos-rebuild switch --flake .#$(hostname) --print-build-logs";
    };
  };
}