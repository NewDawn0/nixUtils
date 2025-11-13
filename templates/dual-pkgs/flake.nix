{
  description = "Dual packages flake template";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    utils = {
      url = "github:NewDawn0/nixUtils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = args @ {
    self,
    utils,
    ...
  }: {
    checks = utils.lib.eachSystem {} (
      p:
        with p; {
          deadnix = pkgs.runCommand "deadnix" {
            nativeBuildInputs = [pkgs.deadnix];
          } "deadnix --fail ${./.} && touch $out";
        }
    );
    formatter = utils.lib.eachSystem {} (p: p.pkgs.alejandra);
    overlays.default = _: prev: {
      YOUR-PACKAGE = self.packages.${prev.system}.default;
    };
    packages =
      utils.lib.eachSystem
      {
        srcs = with args; {
          pkgs = nixpkgs;
          unstable = nixpkgs-unstable;
        };
      }
      (
        p:
          with p; {
            default = pkgs.hello;
            hello = pkgs.hello;
            hello-unstable = unstable.hello;
          }
      );
  };
}
