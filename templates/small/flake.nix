{
  description = "Minimal flake template";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-utils = {
      url = "github:NewDawn0/nixUtils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    };
  };
  outputs = { nix-utils, ... }: {
    packages = nix-utils.lib.eachSystem { } (
      pkgs: unstable: {
        default = pkgs.hello;
      }
    );
  };
}
