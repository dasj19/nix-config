{
  imports = [
    # Profiles.
    ./base.nix
  ];

  config = {
    # Don't build documentation on servers.
    documentation.enable = false;
    documentation.man.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;
    documentation.doc.enable = false;
    documentation.dev.enable = false;
  };
}