{
  description = "Complete flake template";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-utils = {
      url = "github:NewDawn0/nixUtils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    };
  };
  outputs =
    args@{ self, nix-utils, ... }:
    let
      perSystem = nix-utils.lib.eachSystem { };
    in
    {
      checks = perSystem (
        pkgs: _: {
          deadnix = pkgs.runCommand "deadnix" {
            nativeBuildInputs = [ pkgs.deadnix ];
          } "deadnix --fail ${./.} && touch $out";
        }
      );
      devShells = perSystem (
        pkgs: _: {
          default = pkgs.mkShell { };
        }
      );
      formatter = perSystem (pkgs: _: pkgs.alejandra);
      overlays.default = final: prev: {
        YOUR-PACKAGE = self.packages.${prev.system}.default;
      };
      packages = perSystem (
        pkgs: unstable: {
          default = pkgs.hello;
        }
      );
    };
}
