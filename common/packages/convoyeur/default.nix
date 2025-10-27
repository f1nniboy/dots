{
  lib,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  pkg-config,
  alsa-lib,
}:

rustPlatform.buildRustPackage rec {
  pname = "convoyeur";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "classabbyamp";
    repo = "convoyeur";
    tag = "v${version}";
    hash = "sha256-DCEcEfTl3Me/0KL9YnyJfxZR8gCBG9pzcK/RhpN8mdY=";
  };

  cargoHash = "sha256-X8nt0m01qiy2t7dAQKtO42ThUi5sSjZ22ziQMBZAVls=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    alsa-lib
  ];

  meta = with lib; {
    description = "IRCv3 FILEHOST extension adapter to external file upload services";
    homepage = "https://github.com/classabbyamp/convoyeur";
    license = licenses.gpl3Only; # TODO: wrong
    mainProgram = "convoyeur";
  };
}
