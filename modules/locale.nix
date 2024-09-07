{ pkgs, ... }:
{
  # Local time.
  time.timeZone = "Europe/Copenhagen";

  # Internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";
  # Support all locales.
  i18n.supportedLocales = [ "all" ];

  environment.systemPackages = with pkgs; [
    hunspell
    hunspellDicts.en_US
  ];
}
