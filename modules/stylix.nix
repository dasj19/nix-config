{ nixos-artwork, pkgs, ...}:
{
  stylix.enable = true;
  # Theme settings.
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
  stylix.image = "${nixos-artwork.wallpapers.simple-dark-gray}/share/artwork/gnome/nix-wallpaper-simple-dark-gray.png";
  # Cursor settings.
  stylix.cursor.package = pkgs.bibata-cursors;
  stylix.cursor.name = "Bibata-Modern-Classic";
  # Font settings.
  stylix.fonts.serif.package = pkgs.ubuntu-classic;
  stylix.fonts.serif.name = "Ubuntu Classic";
  stylix.fonts.sansSerif.package = pkgs.ubuntu-sans;
  stylix.fonts.sansSerif.name = "Ubuntu Sans";
  stylix.fonts.monospace.package = pkgs.fira-code-nerdfont;
  stylix.fonts.monospace.name = "FiraCode";
}