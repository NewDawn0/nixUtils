{
  description = "Your awesome flake";

  inputs = {
    utils.url = "github:NewDawn0/nixUtils";
  };

  outputs = { utils, ... }@inputs: {
    packages = utils.lib.eachSystem { } (pkgs: {
      default = pkgs.hello;
    });
  };
}
