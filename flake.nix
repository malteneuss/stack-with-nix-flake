{
  description = "my project description";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        hPkgs =
          pkgs.haskell.packages."ghc8107"; # need to match Stackage LTS version from stack.yaml resolver
        # ghc = hPkgs.ghc.overrideAttrs (oldAttrs: {
        #   # Add external C libraries to GHC
        #   buildInputs = oldAttrs.buildInputs
        #     ++ [ pkgs.zlib pkgs.zlib.dev pkgs.zlib.out ];
        # });
        # pkgs.haskell.packages."ghc902"; # need to match Stackage LTS version
        myDevTools = with pkgs; [
          hPkgs.ghc # GHC compiler in the desired version (will be available on PATH)
          hPkgs.cabal-install
          hPkgs.ghcid # Continous terminal Haskell compile checker
          hPkgs.ormolu # Haskell formatter
          hPkgs.hlint # Haskell codestyle checker
          hPkgs.hoogle # Lookup Haskell documentation
          hPkgs.haskell-language-server # LSP server for editor
          hPkgs.implicit-hie # auto generate LSP hie.yaml file from cabal
          hPkgs.retrie # Haskell refactoring tool
          stack-wrapped
          zlib
        ];
        # Wrap Stack to configure Nix integration and target the correct Stack-Nix file
        #
        # - nix: Enable Nix support
        # - no-nix-pure: Pass environment variables, like `NIX_PATH`
        # - nix-shell-file: Specify the Nix file to use (otherwise it uses `shell.nix` by default)
        # --nix           # Enable Nix integration
        # --system-ghc    # Use the existing GHC on PATH (will come from this Nix file)
        # --no-install-ghc  # Don't try to install GHC if no matching GHC found on PATH
        stack-wrapped = pkgs.symlinkJoin {
          name = "stack";
          paths = [ pkgs.stack ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/stack \
              --add-flags "\
                --no-nix \
                --system-ghc \
                --no-install-ghc \
              "
          '';
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = myDevTools;

          # Configure the Nix path to our own `pkgs`, to ensure Stack-with-Nix uses the correct one rather than the global <nixpkgs> when looking for the right `ghc` argument to pass in `nix/stack-integration.nix`
          # See https://nixos.org/nixos/nix-pills/nix-search-paths.html for more information
          NIX_PATH = "nixpkgs=" + pkgs.path;
          # Make external Nix c libraries like zlib known to GHC, like pkgs.haskell.lib.buildStackProject does
          # https://github.com/NixOS/nixpkgs/blob/d64780ea0e22b5f61cd6012a456869c702a72f20/pkgs/development/haskell-modules/generic-stack-builder.nix#L38
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath myDevTools;
        };
        # devShells.default = pkgs.haskell.lib.buildStackProject {
        #   inherit ghc;
        #   name = "haskell-stack-flake-nix";
        #   buildInputs = myDevTools;
        # };
      });
}
