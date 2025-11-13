{nixpkgs}: let
  inherit (nixpkgs.lib) all assertMsg isAttrs isList isString genAttrs mapAttrs;
  chk = {
    config = x: assertMsg (isAttrs x) "config must be an attrset";
    overlays = x: assertMsg (isList x && all isString x) "overlays must be a list";
    srcs = x: assertMsg (isAttrs x && x != {}) "srcs must be an attrset";
  };
  eachSystem = {
    config ? {},
    overlays ? [],
    srcs ? {pkgs = nixpkgs;},
    systems ? ["x86_64-linux" "x86_64-darwin"],
  }: f:
    assert chk.config config;
    assert chk.overlays overlays;
    assert chk.srcs srcs;
      genAttrs systems (system:
        f
        (
          mapAttrs (_: src:
            import src {
              inherit config overlays system;
            })
          srcs
        ));
in {inherit eachSystem;}
