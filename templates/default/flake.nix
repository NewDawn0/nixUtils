{
  description = "Default flake template";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=25.05";
    utils = {
      url = "github:NewDawn0/nixUtils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    utils,
    ...
  }: let
  in {
    checks = utils.lib.eachSystem {} (p:
      with p; {
        deadnix = pkgs.runCommand "deadnix" {
          nativeBuildInputs = [pkgs.deadnix];
        } "deadnix --fail ${./.} && touch $out";
      });
    formatter = utils.lib.eachSystem {} (p: p.pkgs.alejandra);
    overlays.default = _: prev: {
      YOUR-PACKAGE = self.packages.${prev.system}.default;
    };
    packages = utils.lib.eachSystem {} (p:
      with p; {
        default = pkgs.hello;
      });
  };
}
