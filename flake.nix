{
  description = "Reusable nix flake utility functions";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nix-systems.url = "github:nix-systems/default";
  };

  outputs = { nixpkgs, nix-systems, ... }:
    let
      mkDefaultPkgs = system: nixpkgs.legacyPackages.${system};
      eachSystem =
        { nixpkgs ? nixpkgs, systems ? nix-systems, mkPkgs ? mkDefaultPkgs }:
        f:
        nixpkgs.lib.genAttrs systems (system: let pkgs = mkPkgs; in f pkgs);
      basic = {
        path = ./templates/basic;
        description = "nix flake init -t nixUtils#basic";
      };
      full = {
        path = ./templates/full;
        description = "nix flake init -t nixUtils#full";
      };
    in {
      lib = { inherit eachSystem; };
      templates = {
        inherit basic full;
        default = basic;
      };
    };
}
