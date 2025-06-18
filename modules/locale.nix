{ pkgs, ... }:
{

  config = {
    # Local time.
    time.timeZone = "Europe/Copenhagen";

    # Internationalization properties.
    i18n.defaultLocale = "en_DK.UTF-8";
    # Support all locales.
    i18n.supportedLocales = [ "all" ];
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "da_DK.UTF-8";
      LC_IDENTIFICATION = "da_DK.UTF-8";
      LC_MEASUREMENT = "da_DK.UTF-8";
      LC_MONETARY = "da_DK.UTF-8";
      LC_NAME = "da_DK.UTF-8";
      LC_NUMERIC = "da_DK.UTF-8";
      LC_PAPER = "da_DK.UTF-8";
      LC_TELEPHONE = "da_DK.UTF-8";
      LC_TIME = "da_DK.UTF-8";
    };

    environment.systemPackages = with pkgs; [
      hunspell
      hunspellDicts.en_US
    ];
  };
}
