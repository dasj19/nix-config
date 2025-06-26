{
  config = {
    # Configure keyboard layout in X11.
    services.xserver.xkb.layout = "esrodk,es,dk,ro";
    # Configure console keyboard layout.
    console.keyMap = "es";

    # Adding an extra layout.
    services.xserver.xkb.extraLayouts.esrodk.description = "Spanish +ro/dk diacritics";
    services.xserver.xkb.extraLayouts.esrodk.languages = ["dan" "eng" "rum" "spa"];
    services.xserver.xkb.extraLayouts.esrodk.symbolsFile = ./esrodk;
  };
}