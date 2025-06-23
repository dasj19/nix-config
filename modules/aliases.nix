{
  config = {
    # Shell aliases.
    # Some are inspired from:
    # https://www.cyberciti.biz/tips/bash-aliases-mac-centos-linux-unix.html
    # https://github.com/vikaskyadav/awesome-bash-alias
    # https://opensource.com/article/19/7/bash-aliases
    environment.shellAliases = {
      # Eza for well-known ls aliases, we still keep vanilla ls.
      ll        = "eza -lh --icons --grid --group-directories-first";
      lg        = "eza -lh --icons --grid --group-directories-first --git";
      la        = "eza -lah --icons --grid --group-directories-first";
      lag       = "eza -lah --icons --grid --group-directories-first --git";
      # List files sorted by size ascending and descending. List by mod time.
      lt        = "du -sh * | sort -h";
      lr        = "du -sh * | sort -rh";
      left      = "ls -t -1";
      # Change file permissions.
      cha       = "chmod a+rwx";
      chr       = "chmod a+r";
      chx       = "chmod a+x";
      chw       = "chmod a+w";
      # Assign ownership to current user, current group.
      cho       = "chown $(whoami):$(id -gn $(whoami))";
      # Git shortcuts.
      gs        = "git status";
      ga        = "git add";
      gc        = "git commit";
      gch       = "git checkout";
      gp        = "git push";
      gu        = "git pull";
      gd        = "git diff";
      gl        = "git log";
      g1        = "git log --oneline";
      glp       = "git log -p";
      gf        = "git fetch";
      gm        = "git merge";
      gmu       = "git merge upstream/master";
      # Quick(er) navigation.
      ".."      = "cd ..";
      ".2"      = "cd ../../";
      ".3"      = "cd ../../../";
      ".4"      = "cd ../../../../";
      ".5"      = "cd ../../../../../";
      h         = "cd ~";
      b         = "cd -";
      c         = "clear";
      r         = "sudo -i";
      # Utils. background jobs, history shortcuts, simplified list of mounted partitions.
      j         = "jobs -l";
      o         = "history";
      o1        = "history 10";
      o2        = "history 20";
      o3        = "history 30";
      mnt       = ''mount | awk -F " " "{ printf \"%s\t%s\n\",\$1,\$3; }" | column -t | egrep ^/dev/ | sort'';
      # Info about memory, cpu and gpu.
      meminfo   = "free -m -l -t -h";
      cpuinfo   = "lscpu";
      gpuinfo   = "lshw -C display";
      # Processes eating memory, and cpu. Files taking most space. Total used space.
      psmem     = "ps auxf | sort -nr -k 4 | head -10";
      pscpu     = "ps auxf | sort -nr -k 3 | head -10";
      most      = "du -hsx * | sort -rh | head -10";
      total     = "df -hl --total | grep  -E '(Use(d|%)|total)'";
      # Development. Get request headers with and without compression; open DDG in a browser.
      header    = "curl -I";
      hd        = "curl -I";
      zheader   = "curl -I --compressed";
      zh        = "curl -I --compressed";
      ff        = "xdg-open https://ddg.gg";
      ddg       = "xdg-open https://ddg.gg";
      # Networking. public ip, local ips, open ports, internal ports, speed test.
      myip      = "curl http://icanhazip.com";
      lip       = "ip addr show | grep \"inet\\b\" | awk \'{print $2,$NF}\'";
      op        = "nmap localhost -p 0-65535";
      p         = "ping 1.1";
      ports     = "netstat -tulanp";
      t         = "speedtest-cli";
      f         = "sudo iptables --list-rules";
      firewall  = "sudo iptables --list-rules";
      # Create a dir and enter it. Change dir and list files.
      # @see https://stackoverflow.com/a/55620350
      indir   = "function indir; mkdir $argv; cd $argv; end; indir";
      cl      = "function cl; cd $argv; ls; end; cl";
      # Nix specific. OS update. Flake update.
      osup    = "sudo nixos-rebuild switch --flake .#$(hostname) --print-build-logs";
      flup    = "nix flake update";
    };
  };
}