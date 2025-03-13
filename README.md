# nixUtils

Reusable Nix flake utility functions for simplifying multi-system package definitions.

## Features

- **`eachSystem`**: Define outputs for multiple NixOS-supported systems with ease.
- Support for custom `nixpkgs` inputs and overlays.
- Fully compatible with the Nix flakes ecosystem.
- Support for only partial platforms

## Installation

### Using Templates

- To use the basic template

```bash
nix flake init -t github:NewDawn0/nixUtils
```

- To use the full template, which offers overlays and other package creation settings

```bash
nix flake init -t github:NewDawn0/nixUtils#full
```

### Manual

To use `nixUtils` in your Nix flake, add it as an input:

```nix
{
  inputs = {
    nixUtils.url = "github:NewDawn0/nixUtils";
  };
}
```

Then, access the `eachSystem` utility via `nixUtils.lib.eachSystem`.

## Usage

### Basic Example

The following example defines a package output for multiple systems using the default `nixpkgs`:

```nix
{
  description = "Example usage of nixUtils";

  inputs = {
    nixUtils.url = "github:NewDawn0/nixUtils";
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixUtils, nixpkgs, ... }: {
    packages = nixUtils.lib.eachSystem {} (pkgs: {
      default = pkgs.hello;
    });
  };
}
```

### Custom `systems` Input

You can provide a custom `systems` input if you want to make the package only buildable for specific platforms

```nix
{
  description = "Example with custom nixpkgs";

  inputs = {
    nixUtils.url = "github:NewDawn0/nixUtils";
  };

  outputs = { self, nixUtils, customNixpkgs, ... }: {
    packages = nixUtils.lib.eachSystem { systems = ["x86_64-linux" "aarch64-linux"]; } (pkgs: {
      default = pkgs.hello;
    });
  };
}
```

### Using Overlays

You can define a custom package set with overlays and pass it via `mkPkgs`:

```nix
{
  description = "Example with overlays";

  inputs = {
    nixUtils.url = "github:NewDawn0/nixUtils";
    overlay.url = "github:Some/example-overlay";
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixUtils, overlay, nixpkgs, ... }: let
    myMkPkgs = system: import nixpkgs {
      system = system;
      overlays = [ overlay.overlays.default ];
    };
  in {
    packages = nixUtils.lib.eachSystem { mkPkgs = myMkPkgs; } (pkgs: {
      default = pkgs.hello;
    });
  };
}
```

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests to improve this project.

## License

This project is licensed under the [MIT License](LICENSE).

## Acknowledgments

- [NixOS](https://nixos.org) for their incredible package manager.
- The open-source community for their contributions to Nix and related tools.
