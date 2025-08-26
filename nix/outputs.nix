{ inputs, system }:

let
  inherit (pkgs) lib;

  pkgs = import ./pkgs.nix { inherit inputs system; };

  utils = import ./utils.nix { inherit pkgs lib; };

  project = import ./project.nix { inherit inputs pkgs lib; };

  mkShell = ghc: import ./shell.nix { inherit inputs pkgs lib project utils ghc; };

  packages = {
    plutus-accumulator-test = project.flake'.packages."plutus-accumulator:test:test";
    plutus-accumulator-bench = project.flake'.packages."plutus-accumulator:bench:bench";
  };

  devShells = rec {
    default = ghc967; 
    ghc967 = mkShell "ghc967"; 
  };

  projectFlake = project.flake {};

  defaultHydraJobs = { 
    ghc967 = projectFlake.hydraJobs.ghc967;
    inherit packages; 
    inherit devShells;
    required = utils.makeHydraRequiredJob hydraJobs; 
  };

  hydraJobsPerSystem = {
    "x86_64-linux" = defaultHydraJobs; 
    "x86_64-darwin" = defaultHydraJobs;
    "aarch64-linux" = defaultHydraJobs; 
    "aarch64-darwin" = defaultHydraJobs;
  };

  hydraJobs = utils.flattenDerivationTree "-" hydraJobsPerSystem.${system};
in

{
  inherit packages;
  inherit devShells;
  inherit hydraJobs;
}
