{
  description = "Nixos-builder template NixOS config";

  inputs = {
    nixos-builder.url = "github:tt0fu/nixos-builder";
    
    # Do not edit the inputs between the markers. They will get rewritten by
    # `nix run .#generate-inputs` (run automatically by build.sh / update.sh).
    # GENERATED INPUTS START
    home-manager = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:nix-community/home-manager";
    };
    nixpkgs = {
      url = "nixpkgs/nixos-unstable";
    };
    nixpkgs-stable = {
      url = "nixpkgs/nixos-25.11";
    };
    # GENERATED INPUTS END
  };

  outputs =
    inputs:
    (inputs.nixos-builder.lib.outputs {
      inherit inputs;
      settingsPath = ./settings.nix;
      modulesPath = ./modules;
      extraNixpkgs = {
        pkgs-stable = inputs.nixpkgs-stable;
      };
    });
}
