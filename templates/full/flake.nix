{
  description = "Your awesome flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    utils = {
      url = "github:NewDawn0/nixUtils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, self, utils, ... }:
    let
      mkPkgs = { system, overlays ? [ ] }:
        import nixpkgs { inherit system overlays; };
    in {
      overlays.default = final: prev: {
        TODO-PACKAGE-NAME = self.packages.${prev.system}.default;
      };
      packages = utils.lib.eachSystem { inherit mkPkgs; }
        (pkgs: { default = pkgs.hello; });
    };
}
