{
  # Configure keymap in X11
  services.xserver.xkb.layout = "es";

  # Configure console keymap
  console.keyMap = "es";

  # Adding an extra layout.
  services.xserver.xkb.extraLayouts.esrodk = {
    description = "Spanish +ro/dk diacritics";
    languages = ["dan" "eng" "rum" "spa"];
    symbolsFile = ./esrodk;
  };
}