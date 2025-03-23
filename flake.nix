{
  description = "Reusable nix flake utility functions";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nix-systems.url = "github:nix-systems/default";
  };

  outputs = { nixpkgs, nix-systems, ... }:
    let
      mkDefaultPkgs = { system, overlays }:
        import nixpkgs { inherit system overlays; };
      eachSystem = { systems ? (import nix-systems), mkPkgs ? mkDefaultPkgs
        , overlays ? [ ] }:
        f:
        nixpkgs.lib.genAttrs systems
        (system: let pkgs = mkPkgs { inherit system overlays; }; in f pkgs);
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
