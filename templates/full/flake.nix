{
  description = "Your awesome flake";

  inputs = {
    # Other inputs ...
    utils.url = "github:NewDawn0/nixUtils";
  };

  outputs = { self, utils, ... }@inputs: {
    overlays.default = final: prev: {
      TODO-PACKAGE-NAME = self.packages.${prev.system}.default;
    };
    packages = utils.lib.eachSystem {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      config = { };
      overlays = [ ];
    } (pkgs: {
      default = pkgs.hello; # default package
    });
  };
}
