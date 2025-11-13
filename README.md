# nixUtils

<!--toc:start-->
- [nixUtils](#nixutils)
  - [Features](#features)
  - [Installation using templates](#installation-using-templates)
    - [Default template](#default-template)
    - [Dual-Pkgs template](#dual-pkgs-template)
    - [Full template](#full-template)
  - [Reference](#reference)
    - [Top-Level Functions](#top-level-functions)
      - [`eachSystem`](#eachsystem)
    - [Presets](#presets)
      - [Systems](#systems)
      - [Filters](#filters)
    - [Examples](#examples)
      - [Adding an overlay](#adding-an-overlay)
      - [Configuring the package set](#configuring-the-package-set)
      - [Custom systems](#custom-systems)
      - [Unstable as the default package source](#unstable-as-the-default-package-source)
      - [Using unstable alongside the stable package source](#using-unstable-alongside-the-stable-package-source)
  - [Contributing](#contributing)
  - [License](#license)
  - [Acknowledgments](#acknowledgments)
<!--toc:end-->

Reusable Nix flake utility functions for simplifying multi-system package definitions.

## Features

- **`eachSystem`**: Define outputs for multiple NixOS-supported systems with ease.
- Support for multiple package sources. (e.g. **`pkgs`, `unstable`**)
- Support for only partial platforms

## Installation using templates

### Default template

The default template comes bundled with
- Checks for dead code using `deadnix`
- Formatting using `alejandra`
- An overlay template for adding your own packages
- For all Tier-1 support platforms

```bash
nix flake init -t github:NewDawn0/nixUtils          # Or#
nix flake init -t github:NewDawn0/nixUtils#default
```

### Dual-Pkgs template

The dual-pkgs template is the basic template with the addition of unstable as another package source
```bash
nix flake init -t github:NewDawn0/nixUtils#dual-pkgs
```

### Full template

The full template in addition to the features of the default template also includes
- All available flake outputs

```bash
nix flake init -t github:NewDawn0/nixUtils#full
```

## Reference

### Top-Level Functions
#### `eachSystem`
The `eachSystem` allows one to generate outputs for multiple systems.

**Signature:**
```
eachSystem { config, overlays, srcs, systems }: ({system, pkgs, ...}: {})
```
**Arguments:**
- **`config`**: Nixpkgs package configuration
  - Type: `attrs`
  - Default: `{}`
- **`overlays`** List of overlays to apply to the package set
  - Type: `[]`
  - Default: `[]`
- **`srcs`** Nixpkgs package sources
    The keys are passed to the first argument of the second eachSystem closure
  - Type: `attrs`
  - Default: `{pkgs = nixpkgs;}`
- **`systems`** List of systems to generate outputs for
  - See also: [System-presets](#system-presets)
  - Type: `[str]`
  - Default: `["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"]`

**Closure Arguments:**
- **`system`** The current system being generated for
  - Type: `str`
  - Example: `"x86_64-linux"`
- **`srcs...`** The package set attributes for the current system from sources
    Called `pkgs` unless overridden
  - Type: `nixpkgs`
  - Example: `import nixpkgs { system = "x86_64-linux"; }`

### Presets
#### Systems
Predefined list of systems
- **`all`**: All available systems
- **`default`**: Tier-1 supported platforms
- **`tier1`**: Tier-1 supported platforms
- **`tier2`**: Tier-2 supported platforms
- **`tier3`**: Tier-3 supported platforms
- **`arm`**: ARM platforms

#### Filters
Filter systems by attribute

- **`byArch`**: By architecture
  - Args: `str | [str]` Allowed architectures
  - Example: `byArch "x86_64" systems.all`
- **`byOS`**: By operating system
  - Args: `str | [str]` Allowed OSes
  - Example: `byOS "linux" systems.all`
- **`byBits`**: By bits
  - Args: `int | [int]` Allowed bitnesses
  - Example: `byBits 64 systems.all`

These quantifiers can be chained together to create more complex filters.
```nix
systems.all |> byOS ["linux" "darwin"] |> byBits 64 # Using pipes
byBits 64 (byOS ["linux" "darwin"] systems.all)     # Using function composition
```

### Examples
#### Adding an overlay
```nix
{
  description = "Example usage of nixUtils";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=25.05";
    rust-overlay.url = "github:oxalica/rust-overlay";
    utils = {
      url = "github:NewDawn0/nixUtils"
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = args@{ utils, nixpkgs, ... }: {
    packages = utils.lib.eachSystem {
      overlays = with args; [rust-overlay.overlays.default];
    }; (p: with p; {
      default = p.pkgs.hello; # Using rust-overlay
    });
  };
}
```

#### Configuring the package set
```nix
{
  description = "Example usage of nixUtils";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=25.05";
    utils = {
      url = "github:NewDawn0/nixUtils"
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = args@{ utils, nixpkgs, ... }: {
    packages = utils.lib.eachSystem {
      config = { allowUnfree = true; };
    }; (p: with p; {
      default = p.pkgs.hello; # Using unfree packages
    });
  };
}
```

#### Custom systems
```nix
{
  description = "Example usage of nixUtils";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=25.05";
    utils = {
      url = "github:NewDawn0/nixUtils"
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = args@{ utils, nixpkgs, ... }: {
    packages = utils.lib.eachSystem {
      systems = ["x86_64-linux" "aarch64-linux"];               # Passing the systems directly
      systems = utils.lib.systems.all;                          # Using a preset
      systems = with utils.lib; filters.byBits 64 systems.all;  # Using a preset
    }; (p: with p; {
      default = p.pkgs.hello; # Using unfree packages
    });
  };
}
```

#### Unstable as the default package source
```nix
{
  description = "Example usage of nixUtils";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixpkgs-unstable";
    utils = {
      url = "github:NewDawn0/nixUtils"
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { utils, nixpkgs, ... }: {
    packages = utils.lib.eachSystem { }; (p: with p; {
      default = p.pkgs.hello; # Using unstable
    });
  };
}
```

#### Using unstable alongside the stable package source
```nix
{
  description = "Example usage of nixUtils";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs?ref=nixpkgs-unstable";
    utils = {
      url = "github:NewDawn0/nixUtils"
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = args@{ utils, nixpkgs, ... }: {
    packages = utils.lib.eachSystem {
      srcs = with args; {
        pkgs = nixpkgs;
        unstable = nixpkgs-unstable;
      };
    }; (p: with p; {
      default = p.pkgs.hello;           # Using stable
      hello-unstable = unstable.hello;  # Using unstable
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
