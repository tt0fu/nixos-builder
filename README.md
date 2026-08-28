# ttofu's NixOS builder flake

## Installation and usage

See [the template config README](template/README.md)

## Module structure

Each module has the following structure:

```nix
{
  enable = <set to false to disable all module contributions>;
  inputs = <flake input expression>;
  os = <nixos configuration expression>;
  home = <home-manager configuration expression>;
  deps = modules: with modules; [
    <list of modules this module depends on>
  ];
  <any additional attributes that can be referenced with "allModules", "usedModules" or "self" special arguments>
}
```

The generated inputs from the modules live between `# GENERATED INPUTS START` and `# GENERATED INPUTS END` markers in `flake.nix` and should not be edited by hand — they are rewritten by `nix run .#generate-inputs`.

A hypothetical example:

```nix
# modules/example/foo.nix
{
  inputs = { # defines a flake input which will be copied to flake.nix during build time
    foo = {
      url = "github:foo-org/foo";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  os =
  { inputs, pkgs, ... }:
  {
    services.foo = {
      enable = true; # enables the foo service via a nixos option
      package = inputs.foo.packages.${pkgs.stdenv.hostPlatform.system}.default # references a flake input
    }
  };

  home =
  { self, ... }:
  {
    home.packages = [
      self.foo-status-package # installs the "foo-status" package defined below through home-manager
      # can also be referenced as allModules.progs.example.foo.foo-status-package
    ];
  };

  foo-status-package = pkgs.writeShellScriptBin "foo-status"  # defines a derivation for a custom shell script
  ''
    watch fooctl --status
  '';

  deps = modules: with modules; [
    example.bar # sets modules/example/bar.nix as a dependency, which will enable the bar module if the foo module is enabled
  ];
}
```

## Module lists

Module lists (in `settings.nix` and in the `deps` attribute of any module) may reference individual modules or whole directories. Referencing a directory expands it with the following rules:

- If the directory contains a `default.nix`, only that `default.nix` module is
  added - the directory decides its own inclusion logic.
- If the directory doesn't contain a `default.nix`, every `.nix` file and subdirectory in it is added, applying the same rules recursively.