{ pkgs, ... }:
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
    # Search mynixos.com with: "@mn query".
    {
      Alias = "@mn";
      Description = "Search on MyNixOS";
      IconURL = "https://mynixos.com/favicon-32x32.png";
      Method = "GET";
      Name = "MyNixOS";
      URLTemplate = "https://mynixos.com/search?q={searchTerms}";
    }
    # Search NixOS Discourse with: "@nd query".
    {
      Alias = "@nd";
      Description = "Search NixOS Discourse";
      IconURL = "https://discourse.nixos.org/favicon.ico";
      Method = "GET";
      Name = "NixOS Discourse";
      URLTemplate = "https://discourse.nixos.org/search?q={searchTerms}";
    }
    # Search the official NixOS Wiki with: "@nw query".
    {
      Alias = "@nw";
      Description = "Search NixOS Wiki";
      IconURL = "https://wiki.nixos.org/favicon.ico";
      Method = "GET";
      Name = "NixOS Wiki";
      URLTemplate = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
    }
    # Search GitHub with: "@gh query".
    {
      Alias = "@gh";
      Description = "Search on GitHub";
      IconURL = "https://github.githubassets.com/favicons/favicon.png";
      Method = "GET";
      Name = "GitHub";
      URLTemplate = "https://github.com/search?q={searchTerms}&type=repositories";
    }
    # Search DuckDuckGo with: "@ddg query".
    {
      Alias = "@ddg";
      Description = "Search on DuckDuckGo";
      IconURL = "https://duckduckgo.com/favicon.ico";
      Method = "GET";
      Name = "DuckDuckGo";
      URLTemplate = "https://duckduckgo.com/?q={searchTerms}";
    }
    # Search Wikipedia with: "@wp query".
    {
      Alias = "@wp";
      Description = "Search on Wikipedia";
      IconURL = "https://en.wikipedia.org/static/favicon/wikipedia.ico";
      Method = "GET";
      Name = "Wikipedia";
      URLTemplate = "https://en.wikipedia.org/w/index.php?search={searchTerms}";
    }
  ];
  programs.firefox.policies.Homepage.StartPage = "previous-session";

  # Privacy preferences.
  programs.firefox.policies.Preferences."extensions.pocket.enabled".Value = false;
  programs.firefox.policies.Preferences."browser.newtabpage.pinned".Value = "";
  programs.firefox.policies.Preferences."browser.topsites.contile.enabled".Value = false;
  programs.firefox.policies.Preferences."browser.newtabpage.activity-stream.showSponsored".Value =
    false;
  programs.firefox.policies.Preferences."browser.newtabpage.activity-stream.system.showSponsored".Value =
    false;
  programs.firefox.policies.Preferences."browser.newtabpage.activity-stream.showSponsoredTopSites".Value =
    false;

  # Setup default search engine.
  programs.firefox.policies.Preferences."browser.search.defaultenginename".Value = "DuckDuckGo";
  programs.firefox.policies.Preferences."browser.search.order.1".Value = "DuckDuckGo";
  programs.firefox.policies.Preferences."browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.searchEngines".Value =
    "DuckDuckGo";

  # Translations.
  programs.firefox.policies.Preferences."browser.translations.enable".Value = true;
  programs.firefox.policies.Preferences."browser.translations.automaticallyPopup".Value = true; # revisit this setting.
  programs.firefox.policies.Preferences."browser.translations.neverTranslateLanguages".Value =
    "da,en,es,pt,ro";

  # Disable geolocation prompts.
  programs.firefox.policies.Preferences."geo.enabled".Value = false;

  # Apply extensions to all instances of Firefox system-wide.
  programs.firefox.policies.ExtensionSettings = {
    # Block all extension installations.
    "*" = {
      installation_mode = "blocked";
      blocked_install_message = "Install extensions via nix config!";
    };
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
      install_url = "https://addons.mozilla.org/firefox/downloads/file/4567995/flagfox-6.1.90.xpi";
      installation_mode = "force_installed";
      private_browsing = true;
      updates_disabled = true;
    };
    "jid1-KKzOGWgsW3Ao4Q@jetpack" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/i-dont-care-about-cookies/latest.xpi";
      installation_mode = "force_installed";
      private_browsing = true;
      updates_disabled = true;
    };
    "wayback_machine@mozilla.org" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/wayback-machine_new/latest.xpi";
      installation_mode = "force_installed";
      private_browsing = true;
      updates_disabled = true;
    };
  };

  programs.chromium.enable = true;
  # See available extensions at https://chrome.google.com/webstore/category/extensions
  programs.chromium.extensions = [
    "hjdoplcnndgiblooccencgcggcoihigg" # Terms of Service; Didn’t Read
    "mdjildafknihdffpkfmmpnpoiajfjnjd" # Consent-O-Matic
    "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock for YouTube
    "gebbhagfogifgggkldgodflihgfeippi" # Return YouTube Dislike
    "kimbeggjgnmckoikpckibeoaocafcpbg" # YouTube Captions Search
    "gcbommkclmclpchllfjekcdonpmejbdp" # HTTPS Everywhere
    "fploionmjgeclbkemipmkogoaohcdbig" # Page load time
    "fhnegjjodccfaliddboelcleikbmapik" # Tab Counter
    "fpnmgdkabkmnadcjpehmlllkndpkmiak" # Wayback Machine
    "millncjiddlpgdmkklmhfadpacifaonc" # GNU Taler Wallet
  ];
  # See available options at https://chromeenterprise.google/policies/
  programs.chromium.extraOpts = {
    # Disable browser sign-in functionality.
    "BrowserSignin" = 0;
    # Disable the profile creation prompt on startup.
    "BrowserAddPersonEnabled" = false;
    # Disable synchronization features.
    "SyncDisabled" = true;
    # Disable password manager.
    "PasswordManagerEnabled" = false;
    # Disable autofill features.
    "AutofillAddressEnabled" = false;
    # Disable credit card autofill.
    "AutofillCreditCardEnabled" = false;
    # Disable built-in DNS client.
    "BuiltInDnsClientEnabled" = false;
    # Disable usage statistics and crash reports.
    "MetricsReportingEnabled" = false;
    # Disable Google Safe Browsing.
    "SafeBrowsingEnabled" = false;
    "SafeBrowsingExtendedReportingEnabled" = false;
    # Disable search suggestions.
    "SearchSuggestEnabled" = false;
    # Disable alternate error pages. They often contact Google servers.
    "AlternateErrorPagesEnabled" = false;
    # Disable URL-keyed anonymized data collection.
    "UrlKeyedAnonymizedDataCollectionEnabled" = false;
    # Enable spellchecking.
    "SpellcheckEnabled" = true;
    # Set preferred spellcheck languages.
    "SpellcheckLanguage" = [
      "da"
      "en-US"
      "ro"
    ];
    # Disable printing via Google Cloud Print.
    "CloudPrintSubmitEnabled" = false;
    # Block third-party cookies.
    "BlockThirdPartyCookies" = true;
    # Disable voice interaction features.
    "VoiceInteractionHotwordEnabled" = false;
    # Disable autoplay of media.
    "AutoplayAllowed" = false;
    # Disable asking for making the system's default browser.
    "DefaultBrowserSettingEnabled" = false;
    # Disable extension installations from outside the web store.
    "ExtensionInstallSources" = [
      "https://chrome.google.com/webstore/detail/*"
    ];
    # Block all extension installations by default.
    "ExtensionInstallBlocklist" = [ "*" ];
    # Disable translation features.
    "TranslateEnabled" = false;
    # Set homepage to blank.
    "HomepageLocation" = "about:blank";
    "HomepageIsNewTabPage" = false;
    # Set default search engine to DuckDuckGo.
    "DefaultSearchProviderEnabled" = true;
    "DefaultSearchProviderName" = "DuckDuckGo";
    "DefaultSearchProviderSearchURL" = "https://duckduckgo.com/?q={searchTerms}";
    # Disable prefetching of pages.
    "NetworkPredictionOptions" = 0;
    # Disable autofill of forms.
    "AutofillEnabled" = false;
    # Disable the built-in PDF viewer.
    "DisablePDFViewer" = true;
    # Disable the reading list feature.
    "ReadingListEnabled" = false;
    # Disable the Chrome Cleanup Tool.
    "ChromeCleanupEnabled" = false;
    # Disable the Chrome Cleanup Tool's reporting feature.
    "ChromeCleanupReportingEnabled" = false;
    # Disable the new tab page.
    "NewTabPageLocation" = "about:blank";
    "NewTabPageEnabled" = false;
    # Disable the suggestions on the new tab page.
    "NewTabPageSuggestionsEnabled" = false;
    # Disable the bookmarks bar.
    "ShowBookmarkBar" = false;
    # Disable the "What's New" page on updates.
    "ShowWhatsNewPage" = false;
    # Disable the "Welcome" page on first run.
    "ShowWelcomePage" = false;
    # Disable the "Chrome Tips" page.
    "ShowTipsPage" = false;
    # Disable the "Get Started" page.
    "ShowGetStartedPage" = false;
    # Disable the "Help Center" page.
    "ShowHelpCenterPage" = false;
    # Disable the "Feedback" page.
    "ShowFeedbackPage" = false;
  };

  environment.systemPackages = with pkgs; [
    # Internet browsers.
    brave
    firefox-devedition
    tor-browser
    chromium
    # ungoogled-chromium
  ];
}
