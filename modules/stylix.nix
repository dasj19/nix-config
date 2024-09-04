{ pkgs, ...}:
{
  stylix.enable = true;
  # Theme settings.
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
  stylix.image = "${pkgs.adapta-backgrounds}/share/backgrounds/adapta/tealized.jpg";
  stylix.polarity = "either";
  stylix.opacity.applications = 0.8;

  # Cursor settings.
  stylix.cursor.package = pkgs.bibata-cursors;
  stylix.cursor.name = "Bibata-Modern-Classic";
  # Font settings.
  stylix.fonts.serif.package = pkgs.ubuntu-classic;
  stylix.fonts.serif.name = "Ubuntu Classic";
  stylix.fonts.sansSerif.package = pkgs.fira-code-nerdfont;
  stylix.fonts.sansSerif.name = "UbuntuMono Nerd Font";
  stylix.fonts.monospace.package = pkgs.fira-code-nerdfont;
  stylix.fonts.monospace.name = "FiraCode Nerd Font";

  

  
}