/*
  * base: a profile inherited by all the other profiles.
  * contains: common stuff that are needed on all the machines configured in this repo.
*/
{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./../modules/aliases.nix
    ./../modules/fish.nix
    ./../modules/folders.nix
    ./../modules/keyboard.nix
    ./../modules/locale.nix
    ./../modules/nix.nix
    ./../modules/starship.nix
    ./../modules/users.nix
  ];

  config = {
    # Preferred cross-system Linux kernel - a LTS kernel. 6.12 is good until December 2026.
    # Check if kernel was updated: ls -l /run/{booted,current}-system/kernel*
    boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_12;

    # Enable fwupd - Firmware updater.
    services.fwupd.enable = lib.mkDefault true;

    # Limit the space occupied by logs.
    services.journald.extraConfig = ''
      SystemMaxUse=200M
    '';

    # Log rotation.
    services.logrotate.enable = true;
    services.logrotate.settings.header = {
      compress = true;
    };

    # Base packages are a must for every machine.
    # These should be CLI-only packages.
    environment.systemPackages = with pkgs; [
      # CLI.
      aria2 # Multi-protocol downloader
      bat # Improved version of cat.
      bat-extras.batdiff # Diff in bat style.
      cloc # Calculate lines of code.
      dig # DNS lookup utility.
      dmidecode # DMI table decoder
      dust # Improved version of du.
      eza # Improved version of ls-
      fd # Simple alternative to find.
      gh # Github CLI.
      git # File versioning system CLI.
      htop # Interactive process viewer.
      iftop # Real-time network bandwidth monitor.
      inetutils # Common network programs (ftp, telnet, rsh, etc).
      iotop # Real-time disk I/O viewer.
      jq # CLI Json processor.
      killall # Improved kill command.
      litecli # SQLite CLI client.
      lf # Terminal file manager.
      lsof # List open files.
      lshw # List hardware data.
      legit # Complementary utility for the git command.
      moreutils # Collection of useful CLI utilities.
      ncdu # du with ncurses.
      nmap # Network exploration tool.
      nvme-cli # interface to retrieve nvme metadata and logs.
      pandoc # Document conversion utility.
      pciutils # Inspects and manipulates configuration of PCI devices.
      procs # Retrieve information about active processes.
      pstree # Shows the running process tree.
      pv # Pipe viewer - shows progress of data through a pipe.
      ripgrep-all # Recursive search tool.
      smartmontools # Control utility for SMART disks.
      strace # Trace system calls and signals.
      tcpdump # Network packet analyzer.
      tmux # Terminal multiplexer.
      tree # Displays hierarchical structure of folders.
      usbutils # Tools for working with USB devices.
      unzip # Unzipping cli tool.
      w3m # Text-based web browser.
      wget # Online resource fetcher.
      whois # Domain information lookup utility.
      xz # Compression utility.
      yq # CLI YAML processor.

      # Drivers and Firmware.
      ntfs3g # Driver for NTFS.

      # Encryption.
      age # Age encryption libraries.
      git-crypt # Git supported encryption utility.
      sops # Sops secret manager.
    ];
  };
}
