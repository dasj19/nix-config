{ pkgs, ...}:
{
  stylix.enable = true;
  # Theme settings.
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/da-one-sea.yaml";
  stylix.image = "${pkgs.adapta-backgrounds}/share/backgrounds/adapta/tealized.jpg";
  stylix.polarity = "dark";
  stylix.opacity.applications = 1.0;
  stylix.opacity.desktop = 1.0;

  # Cursor settings.
  stylix.cursor.package = pkgs.bibata-cursors;
  stylix.cursor.name = "Bibata-Modern-Classic";
  # Font settings.
  stylix.fonts.serif.package = pkgs.ubuntu-classic;
  stylix.fonts.serif.name = "Ubuntu Classic";
  stylix.fonts.sansSerif.package = pkgs.nerd-fonts.ubuntu-sans;
  stylix.fonts.sansSerif.name = "UbuntuSans Nerd Font";
  stylix.fonts.monospace.package = pkgs.nerd-fonts.fira-code;
  stylix.fonts.monospace.name = "FiraMono Nerd Font";
}
