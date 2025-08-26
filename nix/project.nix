{ inputs, pkgs, lib }:

let
  cabalProject = pkgs.haskell-nix.cabalProject' (
    
    { config, pkgs, ... }:

    {
      name = "plutus-accumulator";

      compiler-nix-name = lib.mkDefault "ghc967";

      src = lib.cleanSource ../.;

      flake.variants = {
        ghc967 = {}; # Alias for the default variant
      };
      inputMap = { "https://chap.intersectmbo.org/" = inputs.CHaP; };

      modules = [{
        packages = {};
      }];
    }
  );

in

cabalProject
