{ pkgs ? import <nixpkgs> {}
}:
pkgs.callPackage ./upload-doc-to-hackage.nix {}
