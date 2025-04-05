{
  description = "Reusable nix flake utility functions";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nix-systems.url = "github:nix-systems/default";
  };

  outputs = { nixpkgs, nix-systems, ... }:
    let
      mkPkgs = { system, config ? { }, overlays ? [ ] }:
        import nixpkgs { inherit config system overlays; };
      eachSystem =
        { config ? { }, systems ? (import nix-systems), overlays ? [ ] }:
        f:
        nixpkgs.lib.genAttrs systems (system:
          let pkgs = mkPkgs { inherit config overlays system; };
          in f pkgs);
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
