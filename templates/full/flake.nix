{
  description = "Full flake template";

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
  }: {
    checks = utils.lib.eachSystem {} (
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
    devShells = utils.eachSystem {} (
      p:
        with p; {
          default = pkgs.mkShell {
            packages = with pkgs; [hello];
          };
        }
    );
    formatter = utils.lib.eachSystem {} (p: p.pkgs.alejandra);
    overlays.default = _: prev: {
      YOUR-PACKAGE = self.packages.${prev.system}.default;
    };
    packages = utils.lib.eachSystem {} (
      p:
        with p; {
          default = pkgs.hello;
        }
    );
  };
}
