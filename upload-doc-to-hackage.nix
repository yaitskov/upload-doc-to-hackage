{
  lib,
  stdenv,
  makeWrapper,
  curl,
}: let
  inherit (lib) makeBinPath;
in
  stdenv.mkDerivation rec {
    name = "upload-doc-to-hackage";
    version = "0.1";
    src = ./upload-doc-to-hackage.sh;
    nativeBuildInputs = [makeWrapper];
    buildInputs = [curl];
    unpackCmd = ''
      mkdir test-src
      cp $curSrc test-src/upload-doc-to-hackage.sh
    '';

    installPhase = ''
      install -Dm755 upload-doc-to-hackage.sh $out/bin/upload-doc-to-hackage.sh
      wrapProgram $out/bin/upload-doc-to-hackage.sh --prefix PATH : '${makeBinPath buildInputs}'
    '';
  }
