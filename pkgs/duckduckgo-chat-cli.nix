{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule (finalAttrs: {
  pname = "duckduckgo-chat-cli";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "benoitpetit";
    repo = finalAttrs.pname;
    tag = "v${finalAttrs.version}";
    hash = "sha256-Wx1Aki/Y569Mv3NPNOh09lXwHkPgy5WLjF/XPkjtsag=";
  };

  vendorHash = "sha256-rfTkjcsRjgarKHRg9WWc+zn758xVr96cTRDtFdm+bLY=";

  ldflags = [
    # Provides the application version at compile time.
    "-X main.Version=v${finalAttrs.version}"
  ];

  meta = {
    description = "A powerful CLI tool to interact with DuckDuckGo's AI";
    homepage = "https://github.com/benoitpetit/duckduckgo-chat-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dasj19 ];
    mainProgram = "duckchat";
  };
})
