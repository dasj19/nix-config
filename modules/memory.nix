# memory: compressed swap in RAM and an early OOM killer.
# scope: all machines
#
# zram gives the hosts without disk swap some headroom, and on hosts with disk swap it is used first,
# because zram swap gets a higher priority. systemd-oomd kills the cgroup under sustained memory
# pressure before the kernel OOM killer stalls the machine.

{ lib, ... }:

{
  # Compressed swap device in RAM, override memoryPercent per machine when needed.
  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";
  zramSwap.memoryPercent = lib.mkDefault 50;

  # Watch the memory pressure of all slices, kills at 80% pressure by default.
  systemd.oomd.enable = true;
  systemd.oomd.enableRootSlice = true;
  systemd.oomd.enableSystemSlice = true;
  systemd.oomd.enableUserSlices = true;
}
