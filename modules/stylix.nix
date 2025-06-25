{ nixos-artwork, lib, pkgs, ...}:
{
  stylix.enable = true;
  stylix.targets.qt.enable = lib.mkForce true;
  stylix.targets.qt.platform = lib.mkForce "qtct";
  # Theme settings.
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/da-one-sea.yaml";
  stylix.image = "${nixos-artwork}/wallpapers/nixos-wallpaper-catppuccin-macchiato.png";
  stylix.polarity = "dark";
  stylix.opacity.applications = 1.0;
  stylix.opacity.desktop = 1.0;

  # Cursor settings.
  stylix.cursor.package = pkgs.bibata-cursors;
  stylix.cursor.name = "Bibata-Modern-Classic";
  stylix.cursor.size = 24;
  
  # Font settings.
  stylix.fonts.serif.package = pkgs.ubuntu-classic;
  stylix.fonts.serif.name = "Ubuntu Classic";
  stylix.fonts.sansSerif.package = pkgs.nerd-fonts.ubuntu-sans;
  stylix.fonts.sansSerif.name = "UbuntuSans Nerd Font";
  stylix.fonts.monospace.package = pkgs.nerd-fonts.ubuntu-mono;
  stylix.fonts.monospace.name = "UbuntuMono Nerd Font";
}
