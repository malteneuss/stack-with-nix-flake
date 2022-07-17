# myproject
This project provides a non-invasive Stack+Nix integration. So non-Nix users can build the project as usual while Nix users get everything
setup with Nix. It's an adaption to Nix flake of Tweag's Nix integration guide
https://www.tweag.io/blog/2022-06-02-haskell-stack-nix-shell/ with its corresponding example project https://github.com/tweag/haskell-stack-nix-example
to include typical developer tools like the Haskell Language Server. 

If you have an existing Stack project, you only need to copy the `flake.nix` file, select a GHC version like `ghc8107` that matches the version in the
`stack.yaml` resolver version, and possibly add needed Nix C library packages. In this project we see how to provide the `zlib` C library as a Nix package
for the dummy dependency JuicyPixels Haskell package, which needs Zlib.


## Build
```shell
$ nix develop
[nix-shell]$ stack build
```
