# archivebox: self-hosted internet archiving solution.
# scope: machines hosting a web archive
#
# Removed from nixpkgs while stuck on django 3, packaged here with django 6 and
# the python dependencies that nixpkgs lacks. The abx* versions are pinned by
# archivebox and must be bumped together with it.

{
  fetchFromGitHub,
  lib,
  python3,
}:

let
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
        version = "1.13.242";
        pyproject = true;
        src = pySelf.fetchPypi {
          pname = "abx_dl";
          inherit version;
          hash = "sha256-BIqxrCiL6+j1ijnGmgXTVFz0i+3jRvByf9qjhV8wQdY=";
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
        version = "1.13.474";
        pyproject = true;
        src = pySelf.fetchPypi {
          pname = "abx_plugins";
          inherit version;
          hash = "sha256-Y7fWhxpU+QigchQe6b3Ax6YIEbb5Uw2W8QSQwAmlbhw=";
        };
        build-system = [ pySelf.hatchling ];
        dependencies = with pySelf; [
          abxbus
          abxpkg
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
        version = "2.5.77";
        pyproject = true;
        src = pySelf.fetchPypi {
          inherit pname version;
          hash = "sha256-0ssltJN7FJnLv7qCo4Xx6FKrIVvz2Nkcs1CQwuToGcI=";
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
        version = "1.13.58";
        pyproject = true;
        src = pySelf.fetchPypi {
          inherit pname version;
          hash = "sha256-xNacL2I+mY02TNOyGUBdlp2F31h9YDIEYM2NkUxmzAc=";
        };
        build-system = [ pySelf.hatchling ];
        dependencies = with pySelf; [
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
in
python.pkgs.buildPythonApplication rec {
  pname = "archivebox";
  version = "0.9.74rc338";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ArchiveBox";
    repo = "ArchiveBox";
    tag = "v${version}";
    hash = "sha256-5gwDrIj16OBEaWkQ7iqwve6Yj6fF/09gZItspKcYUsM=";
  };

  build-system = [ python.pkgs.pdm-backend ];

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
      tzdata
      w3lib
    ]
    ++ abx-plugins.optional-dependencies.opencode
    # HTTP/2 support for daphne.
    ++ twisted.optional-dependencies.http2
    ++ twisted.optional-dependencies.tls;

  # Workers like daphne are spawned as `python -m ...` with the bare interpreter,
  # so they only find the python dependencies through PYTHONPATH.
  makeWrapperArgs = [
    "--prefix"
    "PYTHONPATH"
    ":"
    "${placeholder "out"}/${python.sitePackages}:${python.pkgs.makePythonPath dependencies}"
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
