{
  # Configure keymap in X11
  services.xserver.xkb.layout = "esrodk,es,dk,ro";
  # Configure console keymap
  console.keyMap = "es";

  # Adding an extra layout.
  services.xserver.xkb.extraLayouts.esrodk.description = "Spanish +ro/dk diacritics";
  services.xserver.xkb.extraLayouts.esrodk.languages = ["dan" "eng" "rum" "spa"];
  services.xserver.xkb.extraLayouts.esrodk.symbolsFile = ./esrodk;
}