{
  description = "Reusable nix flake utility functions";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nix-systems.url = "github:nix-systems/default";
  };

  outputs = { nixpkgs, nix-systems, ... }:
    let
      # eachSystem: A utility function for defining outputs across multiple systems
      #
      # Arguments:
      # - args: An attribute set with optional parameters:
      #   - nixpkgs: A custom Nixpkgs input. Defaults to the `nixpkgs` input from this flake.
      #   - mkPkgs: A custom function to generate a package set. Defaults to `nixpkgs.legacyPackages.${system}`.
      # - f: A function that takes a package set (`pkgs`) for a system and returns a derivation or attribute set.
      #
      # Behavior:
      # - Uses `nix-systems` to determine the list of supported systems.
      # - Generates outputs for all supported systems by applying `f` to each system's package set.
      #
      # Example:
      #   eachSystem { mkPkgs = customMkPkgs; } (pkgs: {
      #     default = pkgs.hello;
      #   });
      #
      eachSystem = args: f:
        let
          mkNixpkgs = args.nixpkgs or nixpkgs;
          mkPkgs = system: args.mkPkgs or mkNixpkgs.legacyPackages.${system};
        in nixpkgs.lib.genAttrs (import nix-systems)
        (system: let pkgs = mkPkgs system; in f pkgs);
    in { lib = { inherit eachSystem; }; };
}
