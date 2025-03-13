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
          mkPkgs = if builtins.hasAttr "mkPkgs" args
          && builtins.isFunction (args.mkPkgs) then
            args.mkPkgs
          else
            system: mkNixpkgs.legacyPackages.${system};
        in nixpkgs.lib.genAttrs (import nix-systems)
        (system: let pkgs = mkPkgs system; in f pkgs);
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
