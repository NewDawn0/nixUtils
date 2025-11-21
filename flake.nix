{
  description = "Reusable nix flake utility functions";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=25.05";
  };

  outputs = {nixpkgs, ...}: let
    fn = import ./lib/fn.nix {inherit nixpkgs;};
    sys = import ./lib/systems.nix {inherit nixpkgs;};
    lib = {
      inherit (fn) eachSystem;
      inherit (sys) system filters;
    };
  in {
    inherit lib;
    formatter = lib.eachSystem {} (p: p.pkgs.alejandra);
    checks = lib.eachSystem {} (
      p:
        with p; {
          deadnix = pkgs.runCommand "deadnix" {
            nativeBuildInputs = [pkgs.deadnix];
          } "deadnix --fail ${./.} && touch $out";
          typos = pkgs.runCommand "typos" {
            nativeBuildInputs = [pkgs.typos];
          } "typos --format brief && touch $out";
        }
    );
    packages = lib.eachSystem {} (p: {
      default = p.pkgs.hello;
    });
    templates = {
      default = {
        path = ./templates/default;
        description = "Basic flake template";
      };
      full = {
        path = ./templates/full;
        description = "Complete flake template";
      };
      dual-pkgs = {
        path = ./templates/dual-pkgs;
        description = "Basic flake template with stable and unstable pkgs";
      };
    };
  };
}
