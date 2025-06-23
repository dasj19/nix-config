{
  lib,
  buildFishPlugin,
  fetchFromGitHub,
}:
buildFishPlugin {
  pname = "fish-colored-man";
  version = "0-unstable-20240416";
  src = fetchFromGitHub {
    owner = "decors";
    repo = "fish-colored-man";
    rev = "1ad8fff696d48c8bf173aa98f9dff39d7916de0e";
    hash = "sha256-uoZ4eSFbZlsRfISIkJQp24qPUNqxeD0JbRb/gVdRYlA=";
  };
  meta = with lib; {
    description = "Fish shell plugin that brings colors to man pages";
    homepage = "https://github.com/decors/fish-colored-man";
    license = licenses.mit;
    maintainers = [ maintainers.dasj19 ];
  };
}