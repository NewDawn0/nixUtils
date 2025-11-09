{
  description = "Reusable nix flake utility functions";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    nix-systems.url = "github:nix-systems/default";
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    nix-systems,
    ...
  }: let
    eachSystem = {
      config ? {},
      overlays ? [],
      systems ? (import nix-systems),
    }: f:
      nixpkgs.lib.genAttrs systems (
        system: let
          mkPkgs = source: import source {inherit config overlays system;};
          pkgs = mkPkgs nixpkgs;
          pkgs-unstable = mkPkgs nixpkgs-unstable;
        in
          f pkgs pkgs-unstable
      );
    small = {
      path = ./templates/small;
      description = "nix flake init -t nixUtils#small";
    };
    basic = {
      path = ./templates/basic;
      description = "nix flake init -t nixUtils#basic";
    };
    complete = {
      path = ./templates/complete;
      description = "nix flake init -t nixUtils#complete";
    };
    full = {
      path = ./templates/full;
      description = "nix flake init -t nixUtils#full";
    };
  in {
    lib = {inherit eachSystem;};
    formatter = eachSystem {} (pkgs: _: pkgs.alejandra);
    templates = {
      inherit
        basic
        complete
        full
        small
        ;
      default = basic;
    };
  };
}
