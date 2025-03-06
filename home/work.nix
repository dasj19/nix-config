{ pkgs, ... }:

{
  imports = [
    ./laptop.nix
  ];

  # TODO: Update the value of these variables.
  #programs.git.userName = gitSecrets.danielFullname;
  #programs.git.userEmail = gitSecrets.danielWorkEmail;

  programs.fish.enable = true;

  programs.vscode.extensions =
  let
      # Old drupal syntax highlight extension that still does its job.
      vs-code-drupal-vsix = pkgs.vscode-utils.buildVscodeMarketplaceExtension rec {
        mktplcRef = {
          name = "vs-code-drupal";
          version = "0.0.12";
          publisher = "marcostazi";
        };
        vsix = builtins.fetchurl {
          url = "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/marcostazi/vsextensions/VS-code-drupal/0.0.12/vspackage";
          sha256 = "18vghvx9m7lik2rndmwm4xfw3sz7gmgpkzj2irbl6hylyqagpcmh";
        };
        
        unpackPhase = ''
          runHook preUnpack
          unzip ${vsix}
          runHook postUnpack
        '';
      };
  in
  
  with pkgs.vscode-marketplace; with pkgs.vscode-extensions; [

    # Cross-language debugging.
    formulahendry.code-runner

    # Drupal syntax highlighter.
    vs-code-drupal-vsix

    # Git enhancements.
    waderyan.gitblame

    # Language support.
    redhat.vscode-yaml

    # PHP helpers.
    bmewburn.vscode-intelephense-client
    devsense.composer-php-vscode

    # Templating.
    mblode.twig-language
  ];

}
