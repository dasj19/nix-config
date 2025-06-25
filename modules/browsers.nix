{ pkgs, ...}:
{
    # Install firefox.
  programs.firefox.enable = true;
  # Lock preferences in place.
  programs.firefox.preferencesStatus = "locked";
  # Apply preferred policies. Inspired from
  # https://discourse.nixos.org/t/combining-best-of-system-firefox-and-home-manager-firefox-settings/37721
  # https://mozilla.github.io/policy-templates
  programs.firefox.policies.AppAutoUpdate = false;
  programs.firefox.policies.AutofillCreditCardEnabled = false;
  programs.firefox.policies.DisableFirefoxAccounts = true;
  programs.firefox.policies.DisableFirefoxStudies = true;
  programs.firefox.policies.DisableFormHistory = true;
  programs.firefox.policies.DisableMasterPasswordCreation = true;
  programs.firefox.policies.DisablePocket = true;
  programs.firefox.policies.DisableProfileImport = true;
  programs.firefox.policies.DisableTelemetry = true;
  programs.firefox.policies.DisplayBookmarksToolbar = "never";
  programs.firefox.policies.DontCheckDefaultBrowser = true;
  programs.firefox.policies.NoDefaultBookmarks = true;
  programs.firefox.policies.OfferToSaveLogins = false;
  programs.firefox.policies.OfferToSaveLoginsDefault = false;
  programs.firefox.policies.PasswordManagerEnabled = false;
  programs.firefox.policies.SearchBar = "unified";

  programs.firefox.policies.SearchEngines.Default = "DuckDuckGo";
  programs.firefox.policies.SearchEngines.PreventInstalls = true;
  programs.firefox.policies.SkipTermsOfUse = true;
  # Adding extra search engines.
  programs.firefox.policies.SearchEngines.Add = [
    # Search NixOS packages with: "@np package-name".
    {
      Alias = "@np";
      Description = "Search in NixOS Packages";
      IconURL = "https://nixos.org/favicon.png";
      Method = "GET";
      Name = "NixOS Packages";
      URLTemplate = "https://search.nixos.org/packages?from=0&size=200&sort=relevance&type=packages&query={searchTerms}";
    }
    # Search NixOS options with: "@no option-name".
    {
      Alias = "@no";
      Description = "Search in NixOS Options";
      IconURL = "https://nixos.org/favicon.png";
      Method = "GET";
      Name = "NixOS Options";
      URLTemplate = "https://search.nixos.org/options?from=0&size=200&sort=relevance&type=packages&query={searchTerms}";
    }
  ];

  programs.firefox.policies.Homepage.StartPage = "previous-session";

  # Privacy preferences.
  programs.firefox.policies.Preferences."extensions.pocket.enabled".Value = false;
  programs.firefox.policies.Preferences."browser.newtabpage.pinned".Value = "";
  programs.firefox.policies.Preferences."browser.topsites.contile.enabled".Value = false;
  programs.firefox.policies.Preferences."browser.newtabpage.activity-stream.showSponsored".Value = false;
  programs.firefox.policies.Preferences."browser.newtabpage.activity-stream.system.showSponsored".Value = false;
  programs.firefox.policies.Preferences."browser.newtabpage.activity-stream.showSponsoredTopSites".Value = false;

  # Setup default search engine.
  programs.firefox.policies.Preferences."browser.search.defaultenginename".Value = "DuckDuckGo";
  programs.firefox.policies.Preferences."browser.search.order.1".Value = "DuckDuckGo";
  programs.firefox.policies.Preferences."browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.searchEngines".Value = "DuckDuckGo";

  # Translations.
  programs.firefox.policies.Preferences."browser.translations.enable".Value = true;
  programs.firefox.policies.Preferences."browser.translations.automaticallyPopup".Value = true; # revisit this setting.
  programs.firefox.policies.Preferences."browser.translations.neverTranslateLanguages".Value = "da,en,es,pt,ro";

  # Apply extensions to all instances of Firefox system-wide.
  programs.firefox.policies.ExtensionSettings = {
    "uBlock0@raymondhill.net" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
      installation_mode = "force_installed";
      private_browsing = true;
      updates_disabled = true;
    };
    "jid1-MnnxcxisBPnSXQ@jetpack" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
      installation_mode = "force_installed";
      private_browsing = true;
      updates_disabled = true;
    };
    "sponsorBlocker@ajay.app" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
      installation_mode = "force_installed";
      private_browsing = true;
      updates_disabled = true;
    };
    "{1018e4d6-728f-4b20-ad56-37578a4de76b}" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/flagfox/latest.xpi";
      installation_mode = "force_installed";
      private_browsing = true;
      updates_disabled = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # Internet browsers.
    brave
    firefox-devedition
    tor-browser-bundle-bin
    ungoogled-chromium
  ];
}