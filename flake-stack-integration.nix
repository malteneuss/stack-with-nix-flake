{ ghc }:
with (import <nixpkgs> { });

haskell.lib.buildStackProject {
  inherit ghc;
  name = "haskell-stack-flake-nix";
  buildInputs = [ glpk pcre ];
}
