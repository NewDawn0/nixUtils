{
  description = "Your awesome flake";

  inputs = {
    # Other inputs ...
    utils.url = "github:NewDawn0/nixUtils";
  };

  outputs = { self, utils, ... }: {
    overlays.default = final: prev: {
      YOUR-PACKAGE-NAME = self.packages.${prev.system}.default;
    };
    packages = utils.lib.eachSystem { } (pkgs: {
      default = pkgs.hello; # default package
    });
  };
}
