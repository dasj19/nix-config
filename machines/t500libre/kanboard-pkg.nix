{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "kanboard";
  version = "1.2.35";

  src = fetchFromGitHub {
    owner = "kanboard";
    repo = "kanboard";
    rev = "v${version}";
    hash = "sha256-pWtI2Uuf/KbNNFP2To3HuGyGMe/4DERXmnnYuTFfVCY=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/kanboard
    cp -rv . $out/share/kanboard
  '';

  meta = with lib; {
    description = "Kanban project management software";
    homepage = "https://kanboard.org";
    license = licenses.mit;
    maintainers = with maintainers; [ dasj19 ];
  };
}
