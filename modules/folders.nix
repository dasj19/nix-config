{ ... }:
{
  config = {
    # Custom user directories.
    # Run "xdg-user-dirs-update --force" after changing these.
    environment.etc."xdg/user-dirs.defaults".text = ''
      DESKTOP=system/desktop
      DOWNLOAD=downloads
      TEMPLATES=system/templates
      PUBLICSHARE=system/public
      DOCUMENTS=documents
      MUSIC=media/music
      PICTURES=media/photos
      VIDEOS=media/video
    '';
  };
}