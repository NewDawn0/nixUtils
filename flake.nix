{
  description = "Reusable nix flake utility functions";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nix-systems.url = "github:nix-systems/default";
  };

  outputs = { nixpkgs, nix-systems, ... }:
    let
      eachSystem = args: f:
        let
          mkNixpkgs = args.nixpkgs or nixpkgs;
          mkPkgs = system: args.mkPkgs or mkNixpkgs.legacyPackages.${system};
        in nixpkgs.lib.genAttrs (import nix-systems)
        (system: let pkgs = mkPkgs system; in f pkgs);
    in { lib = { inherit eachSystem; }; };
}
