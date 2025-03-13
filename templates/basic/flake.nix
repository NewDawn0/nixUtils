{
  description = "Your awesome flake";

  inputs.utils.url = "github:NewDawn0/nixUtils";

  outputs = { self, utils, ... }: {
    packages = utils.lib.eachSystem { } (pkgs: {
      default = pkgs.hello;
    });
    overlays.default = final: prev: {
      YOUR-PACKAGE-NAME = self.packages.${prev.system}.default;
    };
  };
}
