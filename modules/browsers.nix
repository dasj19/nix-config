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
  # Disable search suggestions.
  programs.firefox.policies.Preferences."browser.search.suggest.enabled".Value = false;
  # Adding extra search engines.
  programs.firefox.policies.SearchEngines.Add = [
    # Search NixOS packages with: "@np package-name".
    {
      Alias = "@np";
      Description = "Search in NixOS Packages";
      IconURL = "https://nixos.org/favicon.ico";
      Method = "GET";
      Name = "NixOS Packages";
      URLTemplate = "https://search.nixos.org/packages?from=0&size=200&channel=unstable&sort=relevance&type=packages&query={searchTerms}";
    }
    # Search NixOS options with: "@no option-name".
    {
      Alias = "@no";
      Description = "Search in NixOS Options";
      IconURL = "https://nixos.org/favicon.ico";
      Method = "GET";
      Name = "NixOS Options";
      URLTemplate = "https://search.nixos.org/options?from=0&size=200&sort=relevance&type=packages&query={searchTerms}";
    }
    # Search mynixos.com with: "@mn query".
    {
      Alias = "@mn";
      Description = "Search on MyNixOS";
      IconURL = "https://mynixos.com/favicon.ico";
      Method = "GET";
      Name = "MyNixOS";
      URLTemplate = "https://mynixos.com/search?q={searchTerms}";
    }
    # Search NixOS Discourse with: "@nd query".
    {
      Alias = "@nd";
      Description = "Search NixOS Discourse";
      IconURL = "https://discourse.nixos.org/uploads/default/optimized/1X/401be373869e12dfe689b9d7eb347f78b1a105f0_2_32x32.png";
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
      IconURL = "https://github.com/favicon.ico";
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
      IconURL = "https://en.wikipedia.org/favicon.ico";
      Method = "GET";
      Name = "Wikipedia";
      URLTemplate = "https://en.wikipedia.org/w/index.php?search={searchTerms}";
    }
    # Search YouTube with: "@yt query".
    {
      Alias = "@yt";
      Description = "Search on YouTube";
      IconURL = "https://www.youtube.com/favicon.ico";
      Method = "GET";
      Name = "YouTube";
      URLTemplate = "https://www.youtube.com/results?search_query={searchTerms}";
    }
    # Search Discogs with: "@dgs query".
    {
      Alias = "@dgs";
      Description = "Search on Discogs";
      IconURL = "https://www.discogs.com/favicon.ico";
      Method = "GET";
      Name = "Discogs";
      URLTemplate = "https://www.discogs.com/search/?q={searchTerms}&type=all";
    }
    # Search IMDb with: "@imdb movie-name".
    {
      Alias = "@imdb";
      Description = "Search on IMDb";
      IconURL = "https://www.imdb.com/favicon.ico";
      Method = "GET";
      Name = "IMDb";
      URLTemplate = "https://www.imdb.com/find?q={searchTerms}";
    }
    # Search eBay with: "@eb item-name".
    {
      Alias = "@eb";
      Description = "Search on eBay";
      IconURL = "https://www.ebay.com/favicon.ico";
      Method = "GET";
      Name = "eBay";
      URLTemplate = "https://www.ebay.com/sch/i.html?_nkw={searchTerms}";
    }
    # Search PriceRunner with: "@pr item-name".
    {
      Alias = "@pr";
      Description = "Search on PriceRunner";
      IconURL = "https://www.pricerunner.dk/favicon.ico";
      Method = "GET";
      Name = "PriceRunner";
      URLTemplate = "https://www.pricerunner.dk/search?query={searchTerms}";
    }
    # Search CVR.dk with: "@cvr company-name".
    {
      Alias = "@cvr";
      Description = "Search on CVR.dk";
      IconURL = "https://datacvr.virk.dk/favicon.ico";
      Method = "GET";
      Name = "CVR.dk";
      URLTemplate = "https://datacvr.virk.dk/soegeresultater?fritekst={searchTerms}";
    }
    # Search Reddit with: "@rd query".
    {
      Alias = "@rd";
      Description = "Search on Reddit";
      IconURL = "https://www.reddit.com/favicon.ico";
      Method = "GET";
      Name = "Reddit";
      URLTemplate = "https://www.reddit.com/search/?q={searchTerms}";
    }
    # Search GitLab with: "@gl query". (Requires login to search)
    {
      Alias = "@gl";
      Description = "Search on GitLab";
      IconURL = "https://gitlab.com/favicon.ico";
      Method = "GET";
      Name = "GitLab";
      URLTemplate = "https://gitlab.com/search?search={searchTerms}";
    }
    # Search Stack Overflow with: "@so question".
    {
      Alias = "@so";
      Description = "Search on Stack Overflow";
      IconURL = "https://stackoverflow.com/favicon.ico";
      Method = "GET";
      Name = "Stack Overflow";
      URLTemplate = "https://stackoverflow.com/search?q={searchTerms}";
    }
    # Search Wordnik with: "@wn word".
    {
      Alias = "@wn";
      Description = "Search on Wordnik";
      IconURL = "https://www.wordnik.com/favicon.ico";
      Method = "GET";
      Name = "Wordnik";
      URLTemplate = "https://www.wordnik.com/words/{searchTerms}";
    }
  ];
  # Start page settings (pick up where I left off).
  programs.firefox.policies.Homepage.StartPage = "previous-session";
  # Don't delete data on shutdown (cookies, sessions, windows, ...)
  programs.firefox.policies.Preferences."privacy.sanitize.sanitizeOnShutdown".Value = false;

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

  # Native file picker instead of a GTK one.
  programs.firefox.policies.Preferences."widget.use-xdg-desktop-portal.file-picker".Value = true;

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
      install_url = "https://addons.mozilla.org/firefox/downloads/file/4598854/ublock_origin-1.67.0.xpi";
      installation_mode = "force_installed";
      private_browsing = true;
      updates_disabled = true;
    };
    "jid1-MnnxcxisBPnSXQ@jetpack" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/file/4570378/privacy_badger17-2025.9.2.xpi";
      installation_mode = "force_installed";
      private_browsing = true;
      updates_disabled = true;
    };
    "sponsorBlocker@ajay.app" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/file/4608179/sponsorblock-6.1.0.xpi";
      installation_mode = "force_installed";
      private_browsing = true;
      updates_disabled = true;
    };
    "{1018e4d6-728f-4b20-ad56-37578a4de76b}" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/file/4609492/flagfox-6.1.92.xpi";
      installation_mode = "force_installed";
      private_browsing = true;
      updates_disabled = true;
    };
    "jid1-KKzOGWgsW3Ao4Q@jetpack" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/file/4202634/i_dont_care_about_cookies-3.5.0.xpi";
      installation_mode = "force_installed";
      private_browsing = true;
      updates_disabled = true;
    };
    "wayback_machine@mozilla.org" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/file/4047136/wayback_machine_new-3.2.xpi";
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
