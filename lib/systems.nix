{nixpkgs}: let
  inherit
    (nixpkgs.lib)
    elem
    isString
    isInt
    all
    assertMsg
    elemAt
    filter
    lists
    match
    splitString
    ;
  asList = x: lists.flatten [x];
  isArm = sys:
    if match ".*arm.*" sys != null
    then true
    else false;
  get = {
    bits = sys:
      if match ".*64.*" sys != null
      then 64
      else 32;
    arch = sys: elemAt (splitString "-" sys) 0;
    OS = sys: elemAt (splitString "-" sys) 1;
  };
  chk = {
    OS = os: assertMsg (all isString os) "OS must be a list of strings";
    arch = arch: assertMsg (all isString arch) "Arch must be a list of strings";
    bits = bits: assertMsg (all isInt bits) "Bits must be a list of ints";
  };

  systems = {
    all = nixpkgs.lib.systems.flakeExposed;
    default = systems.tier1;
    # Support tiers
    tier1 = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    tier2 = [
      "armv7l-linux"
      "riscv64-linux"
      "powerpc64le-linux"
    ];
    tier3 = [
      "i686-linux"
      "armv6l-linux"
      "x86_64-freebsd"
    ];
    # Special
    arm = filter (x: isArm x) systems.all;
  };
  filters = {
    byBits = bits: let
      bits' = asList bits;
    in
      assert chk.bits bits';
        filter (x: elem (get.bits x) bits');
    byArch = arch: let
      arch' = asList arch;
    in
      assert chk.arch arch';
        filter (x: elem (get.arch x) arch');
    byOS = os: let
      os' = asList os;
    in
      assert chk.OS os';
        filter (x: elem (get.OS x) os');
  };
in {
  inherit systems filters;
}
