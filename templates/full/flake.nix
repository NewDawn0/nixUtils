{
  description = "Your awesome flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    utils = {
      url = "github:NewDawn0/nixUtils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { utils, nixpkgs, ... }@inputs:
    let
      mkPkgs = system:
        import nixpkgs {
          inherit system;
          overlays = [ ];
        };
    in {
      packages = utils.lib.eachSystem { inherit mkPkgs; }
        (pkgs: {
          default = pkgs.hello;
        });
    };
}
