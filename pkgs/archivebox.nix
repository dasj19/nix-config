# archivebox: self-hosted internet archiving solution.
# scope: machines hosting a web archive
#
# Removed from nixpkgs while stuck on django 3, packaged here with django 6 and
# the python dependencies that nixpkgs lacks. The abx* versions are pinned by
# archivebox and must be bumped together with it.
#
# The extractors' binaries come from nixpkgs, since the abxpkg installers (apt,
# brew, puppeteer, uv wheels) do not work on NixOS. Only the chrome plugin's
# node libraries, the chromewebstore extensions and the feedparser library are
# still installed by `archivebox install`, their plugins accept no other
# provider for them.

{
  bubblewrap,
  buildNpmPackage,
  chromium,
  defuddle,
  fetchFromGitHub,
  ffmpeg,
  gallery-dl,
  git,
  imagemagick,
  jq,
  lib,
  libjxl,
  liteparse,
  nodejs,
  pnpm,
  poppler-utils,
  python3,
  runCommand,
  ripgrep,
  sonic-server,
  tesseract,
  wget,
  writeShellScriptBin,
  yt-dlp,
}:

let
  # The mercury plugin needs this fork, nixpkgs only has @postlight/parser.
  mercury-parser = buildNpmPackage rec {
    pname = "mercury-parser";
    version = "3.1.2";
    src = fetchFromGitHub {
      owner = "jocmp";
      repo = "mercury-parser";
      tag = "v${version}";
      hash = "sha256-yE/odH1Q0TmiWe0VwcizCxuJuuYard9PEGXQp/5gRpY=";
    };
    npmDepsHash = "sha256-/nFa2ohkfBrze5spT1OFYlgjJN5XJSDOufTGMlCe5aQ=";
    # The built dist/ is committed.
    dontNpmBuild = true;
    npmFlags = [ "--ignore-scripts" ];
    # npm writes the git dependencies into its cache.
    makeCacheWritable = true;
    # --version is parsed but never handled, abxpkg needs it for the min_version.
    postPatch = ''
      substituteInPlace cli.js --replace-fail "  addExtractor || x" "  addExtractor || x, version"
    '';
    # The mercury plugin loads dist/mercury.js next to the resolved binary.
    postInstall = ''
      ln -sf $out/lib/node_modules/@jocmp/mercury-parser/cli.js $out/bin/mercury-parser
    '';
    meta.mainProgram = "mercury-parser";
  };

  # nixpkgs ships 0.0.11, the readability plugin needs at least 0.0.15.
  readability-extractor = buildNpmPackage rec {
    pname = "readability-extractor";
    version = "0.0.15";
    src = fetchFromGitHub {
      owner = "ArchiveBox";
      repo = "readability-extractor";
      tag = "v${version}";
      hash = "sha256-9kFyg8Eh6gTOP42VQPZ11n8b6+I1P/FiOKK75tZDW2A=";
    };
    npmDepsHash = "sha256-mBjrqcvndxU1EDFri2Av8CaTx5Tc76GQmAD81MU9Vx8=";
    dontNpmBuild = true;
    meta.mainProgram = "readability-extractor";
  };

  # The system-wide chromium policies block every extension, including the
  # unpacked ones archivebox loads, so hide them from its browser.
  archiveboxChromium = writeShellScriptBin "chromium" ''
    exec ${lib.getExe bubblewrap} --dev-bind / / --tmpfs /etc/chromium \
      ${lib.getExe chromium} "$@"
  '';

  # nixpkgs ships an older uv_build than the upstream build-system pins.
  relaxUvBuild = ''
    sed -i 's/"uv_build[^"]*"/"uv_build"/' pyproject.toml
  '';

  python = python3.override {
    self = python;
    packageOverrides = pySelf: pySuper: {
      django = pySuper.django_6;

      abx-dl = pySelf.buildPythonPackage rec {
        pname = "abx-dl";
        version = "1.13.277";
        pyproject = true;
        src = pySelf.fetchPypi {
          pname = "abx_dl";
          inherit version;
          hash = "sha256-dJLlARhh9mFegnSxqsIoirE5n1bh0h+yiFbrtfRSLig=";
        };
        build-system = [ pySelf.pdm-backend ];
        # nixpkgs ships psutil 7.2.2, excluded upstream for a macOS-only bug.
        pythonRelaxDeps = [ "psutil" ];
        dependencies = with pySelf; [
          abx-plugins
          abxbus
          abxpkg
          platformdirs
          psutil
          pydantic
          pydantic-settings
          requests
          rich
          rich-click
        ];
        pythonImportsCheck = [ "abx_dl" ];
      };

      abx-plugins = pySelf.buildPythonPackage rec {
        pname = "abx-plugins";
        version = "1.13.578";
        pyproject = true;
        src = pySelf.fetchPypi {
          pname = "abx_plugins";
          inherit version;
          hash = "sha256-22PAQhgCtJ0snFJoi6BCMZhSN5e26n73e4tTaonMDMY=";
        };
        build-system = [ pySelf.hatchling ];
        nativeBuildInputs = [ jq ];
        # The plugins pin the exact versions of their binaries, nixpkgs ships
        # other ones of these three.
        postPatch = ''
          for config in abx_plugins/plugins/*/config.json; do
            jq '(.required_binaries[]? | select(.name | IN("{NODE_BINARY}", "{GALLERYDL_BINARY}", "{CHROME_BINARY}"))) |= del(.min_version, .max_version)' \
              "$config" > "$config.tmp"
            mv "$config.tmp" "$config"
          done
        '';
        # nixpkgs ships an older certifi.
        pythonRelaxDeps = [ "certifi" ];
        dependencies = with pySelf; [
          abxbus
          abxpkg
          certifi
          imagesize
          rich-click
          uv
        ];
        optional-dependencies.opencode = with pySelf; [
          httpx
          requests
          websockets
        ];
        pythonImportsCheck = [ "abx_plugins" ];
      };

      abxbus = pySelf.buildPythonPackage rec {
        pname = "abxbus";
        version = "2.5.79";
        pyproject = true;
        src = pySelf.fetchPypi {
          inherit pname version;
          hash = "sha256-x8aa3zW8OK12N3lupPmJATCZxRDH6OO6nmLJEvM7byY=";
        };
        build-system = [ pySelf.uv-build ];
        postPatch = relaxUvBuild;
        dependencies = with pySelf; [
          pydantic
          typing-extensions
          uuid7
        ];
        pythonImportsCheck = [ "abxbus" ];
      };

      abxpkg = pySelf.buildPythonPackage rec {
        pname = "abxpkg";
        version = "1.13.73";
        pyproject = true;
        src = pySelf.fetchPypi {
          inherit pname version;
          hash = "sha256-LQRlCegu8RESE8ETNr/wEBPKWOP3e1V1+gZ5+bHhbDg=";
        };
        build-system = [ pySelf.hatchling ];
        dependencies = with pySelf; [
          packaging
          platformdirs
          pydantic
          rich-click
          typing-extensions
        ];
        pythonImportsCheck = [ "abxpkg" ];
      };

      base32-crockford = pySelf.buildPythonPackage rec {
        pname = "base32-crockford";
        version = "0.3.0";
        pyproject = true;
        src = pySelf.fetchPypi {
          inherit pname version;
          hash = "sha256-EV9b0yrjK3JANcsC62UGmogk6gjAiFHrgMi59jRDqWk=";
        };
        build-system = [ pySelf.setuptools ];
        pythonImportsCheck = [ "base32_crockford" ];
      };

      django-admin-data-views = pySelf.buildPythonPackage rec {
        pname = "django-admin-data-views";
        version = "0.4.4";
        pyproject = true;
        src = pySelf.fetchPypi {
          pname = "django_admin_data_views";
          inherit version;
          hash = "sha256-JXehYy9vOoXiRS+1JRK9JWlQtbdv16eqNynSUgCL9tw=";
        };
        build-system = [ pySelf.uv-build ];
        postPatch = relaxUvBuild;
        dependencies = with pySelf; [
          django
          django-settings-holder
        ];
      };

      django-object-actions = pySelf.buildPythonPackage rec {
        pname = "django-object-actions";
        version = "5.1.2";
        pyproject = true;
        src = pySelf.fetchPypi {
          pname = "django_object_actions";
          inherit version;
          hash = "sha256-oRrFROW+trMJpQ4YSiCG4eGPZGlwTZYJu+CDqJcqIkU=";
        };
        build-system = [ pySelf.setuptools ];
        dependencies = [ pySelf.django ];
      };

      django-settings-holder = pySelf.buildPythonPackage rec {
        pname = "django-settings-holder";
        version = "0.3.1";
        pyproject = true;
        src = pySelf.fetchPypi {
          pname = "django_settings_holder";
          inherit version;
          hash = "sha256-oN+8at+MHecNAmvWU1juvAFtbjWFxZNL9CFvMJl7mb8=";
        };
        build-system = [ pySelf.uv-build ];
        postPatch = relaxUvBuild;
        dependencies = [ pySelf.django ];
      };

      django-signal-webhooks = pySelf.buildPythonPackage rec {
        pname = "django-signal-webhooks";
        version = "0.3.1";
        pyproject = true;
        src = pySelf.fetchPypi {
          pname = "django_signal_webhooks";
          inherit version;
          hash = "sha256-I9xDm+L96iS3RnJklesaellECAkFZILuvOsVPQUKP1s=";
        };
        build-system = [ pySelf.poetry-core ];
        dependencies = with pySelf; [
          asgiref
          cryptography
          django
          django-settings-holder
          httpx
        ];
      };

      forum-dl = pySelf.buildPythonPackage rec {
        pname = "forum-dl";
        version = "0.3.0";
        pyproject = true;
        src = pySelf.fetchPypi {
          pname = "forum_dl";
          inherit version;
          hash = "sha256-YmnIerB7SU+4iHI0ofWEYag3a5DLJ9NRI6Mdg2/kAjc=";
        };
        build-system = [ pySelf.setuptools ];
        # Never imported, archivebox installs it without too.
        pythonRemoveDeps = [ "cchardet" ];
        dependencies = with pySelf; [
          beautifulsoup4
          html2text
          lxml
          pydantic
          python-dateutil
          requests
          tenacity
          urllib3
          warcio
        ];
        pythonImportsCheck = [ "forum_dl" ];
      };

      # Installed by abxpkg with uv otherwise, but its PyMuPDF wheel needs a
      # libstdc++ that NixOS does not provide globally.
      papers-dl = pySelf.buildPythonPackage rec {
        pname = "papers-dl";
        version = "0.0.25";
        pyproject = true;
        src = pySelf.fetchPypi {
          pname = "papers_dl";
          inherit version;
          hash = "sha256-PROZ071IdZQhSndBZN89YS2oHLl34FbiqZ6lDbYZC3g=";
        };
        build-system = [ pySelf.setuptools ];
        # Every dependency is pinned upstream, bs4 and PyMuPDFb are dummy packages.
        pythonRelaxDeps = true;
        pythonRemoveDeps = [
          "bs4"
          "PyMuPDFb"
        ];
        dependencies = with pySelf; [
          aiohttp
          beautifulsoup4
          cryptography
          easygui
          feedparser
          google
          loguru
          pdf2doi
          pdfminer-six
          pdftitle
          pymupdf
          pypdf2
          pyperclip
          requests
          retrying
          sgmllib3k
          w3lib
        ];
        pythonImportsCheck = [ "papers_dl" ];
      };

      pdf2doi = pySelf.buildPythonPackage rec {
        pname = "pdf2doi";
        version = "1.5.1";
        pyproject = true;
        src = pySelf.fetchPypi {
          inherit pname version;
          hash = "sha256-+QCVSdu/RR2hMPwfXimmHt6/bjtczvud0q0XvpYNXEE=";
        };
        build-system = [ pySelf.setuptools ];
        pythonRelaxDeps = true;
        dependencies = with pySelf; [
          easygui
          feedparser
          google
          pdfminer-six
          pdftitle
          pymupdf
          pypdf2
          pyperclip
          requests
        ];
        pythonImportsCheck = [ "pdf2doi" ];
      };

      pdftitle = pySelf.buildPythonPackage rec {
        pname = "pdftitle";
        version = "0.11";
        pyproject = true;
        src = pySelf.fetchPypi {
          inherit pname version;
          hash = "sha256-geydQn2cdZvm+5vG4HT2QvZhV0fjXy4mDhSy6KoBJ9A=";
        };
        build-system = [ pySelf.setuptools ];
        dependencies = [ pySelf.pdfminer-six ];
        pythonImportsCheck = [ "pdftitle" ];
      };

      # pdf2doi still uses the PdfFileReader API that PyPDF2 3 removed.
      pypdf2 = pySelf.buildPythonPackage rec {
        pname = "pypdf2";
        version = "2.0.0";
        pyproject = true;
        src = pySelf.fetchPypi {
          pname = "PyPDF2";
          inherit version;
          hash = "sha256-bCxobL2tH6bUKoyvtdLwM9F5jdAOE+jXaRtRDFZ++jQ=";
        };
        build-system = [ pySelf.setuptools ];
        pythonImportsCheck = [ "PyPDF2" ];
      };

      sonic-client = pySelf.buildPythonPackage rec {
        pname = "sonic-client";
        version = "1.0.0";
        pyproject = true;
        src = pySelf.fetchPypi {
          inherit pname version;
          hash = "sha256-/jJMc1RnBIjthIR/amcn08tfs2dcubYTltz1cg5aymY=";
        };
        build-system = [ pySelf.setuptools ];
        pythonImportsCheck = [ "sonic" ];
      };

      # The tests need wsgiprox, whose certauth dependency is marked broken.
      warcio = pySuper.warcio.overridePythonAttrs {
        doCheck = false;
        nativeCheckInputs = [ ];
      };

      uuid7 = pySelf.buildPythonPackage rec {
        pname = "uuid7";
        version = "0.1.0";
        pyproject = true;
        src = pySelf.fetchPypi {
          inherit pname version;
          hash = "sha256-jFeqMu50VtPMaMlcRTC8VxZG3vrAGJXPxzVFRJiUpjw=";
        };
        build-system = [ pySelf.setuptools ];
        pythonImportsCheck = [ "uuid_extensions" ];
      };
    };
  };

  # The trafilatura plugin runs the python found next to the resolved binary,
  # as in a uv venv. Only these two are exposed, to not shadow the hooks' python.
  trafilatura =
    let
      env = python.withPackages (ps: [ ps.trafilatura ]);
    in
    runCommand "trafilatura-${python.pkgs.trafilatura.version}" { } ''
      mkdir -p $out/bin
      cp ${env}/bin/trafilatura $out/bin/
      ln -s ${env}/bin/python $out/bin/python
    '';
in
python.pkgs.buildPythonApplication rec {
  pname = "archivebox";
  version = "0.9.77";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ArchiveBox";
    repo = "ArchiveBox";
    tag = "v${version}";
    hash = "sha256-WMFanzQzX6hcIHMM351d6EpEFSBmBEbEpfgmA3UtfV0=";
  };

  build-system = [ python.pkgs.pdm-backend ];

  # nixpkgs ships older versions of these.
  pythonRelaxDeps = [
    "setuptools"
    "twisted"
    "uvicorn"
  ];

  dependencies =
    with python.pkgs;
    [
      abx-dl
      abx-plugins
      abxbus
      abxpkg
      atomicwrites
      base32-crockford
      bleach
      browser-cookie3
      click
      croniter
      daphne
      dateparser
      django
      django-admin-data-views
      django-extensions
      django-ninja
      django-object-actions
      django-signal-webhooks
      django-stubs
      ipython
      markdown
      platformdirs
      psutil
      psycopg
      py-machineid
      pydantic
      pydantic-settings
      requests
      rich
      rich-click
      setuptools
      sonic-client
      supervisor
      toml
      twisted
      tzdata
      uvicorn
      w3lib
    ]
    ++ abx-plugins.optional-dependencies.opencode
    # HTTP/2 support for daphne.
    ++ twisted.optional-dependencies.http2
    ++ twisted.optional-dependencies.tls
    ++ uvicorn.optional-dependencies.standard;

  # Workers like uvicorn are spawned as `python -m ...` with the bare interpreter,
  # so they only find the python dependencies through PYTHONPATH.
  makeWrapperArgs = [
    "--prefix"
    "PYTHONPATH"
    ":"
    "${placeholder "out"}/${python.sitePackages}:${python.pkgs.makePythonPath dependencies}"
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      defuddle
      ffmpeg
      gallery-dl
      git
      imagemagick
      libjxl
      liteparse
      mercury-parser
      nodejs
      pnpm
      poppler-utils
      python.pkgs.forum-dl
      python.pkgs.papers-dl
      readability-extractor
      ripgrep
      sonic-server
      tesseract
      trafilatura
      wget
      yt-dlp
    ])
    # The chrome plugin only knows the puppeteer installer, so give it a path
    # instead of a binary name to look up.
    "--set-default"
    "CHROME_BINARY"
    (lib.getExe archiveboxChromium)
  ];

  # The upstream test suite needs network access and browser binaries.
  doCheck = false;

  pythonImportsCheck = [ "archivebox" ];

  meta = {
    description = "Self-hosted internet archiving solution";
    homepage = "https://github.com/ArchiveBox/ArchiveBox";
    changelog = "https://github.com/ArchiveBox/ArchiveBox/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "archivebox";
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
