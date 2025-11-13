{nixpkgs}: let
  inherit
    (nixpkgs.lib)
    all
    assertMsg
    isAttrs
    isList
    isString
    genAttrs
    mapAttrs
    ;
  sys = import ./systems.nix {inherit nixpkgs;};
  chk = {
    config = x: assertMsg (isAttrs x) "config must be an attrset";
    overlays = x: assertMsg (isList x && all isString x) "overlays must be a list";
    srcs = x: assertMsg (isAttrs x && x != {}) "srcs must be an attrset";
  };
  eachSystem = {
    config ? {},
    overlays ? [],
    srcs ? {
      pkgs = nixpkgs;
    },
    systems ? sys.systems.default,
  }: f:
    assert chk.config config;
    assert chk.overlays overlays;
    assert chk.srcs srcs; let
      mkPkgs = system: srcs:
        mapAttrs (
          _: src:
            import src {
              inherit config overlays system;
            }
        )
        srcs;
    in
      genAttrs systems (system: f ((mkPkgs system srcs) // {inherit system;}));
in {
  inherit eachSystem;
}
