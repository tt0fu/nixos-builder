let
  build = import ./build.nix;
  generateInputs = import ./generate-inputs.nix;

  generateInputsPackage =
    {
      runCommand,
      writeShellScriptBin,
      nix,
      modulesDir,
    }:
    let
      generator = runCommand "generate-inputs-source" { } ''
        mkdir -p $out
        cp ${./generate-inputs.nix} $out/generate-inputs.nix
        cp ${./modules.nix} $out/modules.nix
      '';
    in
    writeShellScriptBin "generate-inputs-${modulesDir}" ''
      set -euo pipefail

      flake_dir="''${1:-$PWD}"
      cd "$flake_dir"
      modules_path="''${2:-./${modulesDir}}"
      flake_path="''${3:-./flake.nix}"

      ${nix}/bin/nix eval --raw --file ${generator}/generate-inputs.nix newFlake \
        --arg modulesPath $modules_path \
        --arg flakePath $flake_path > flake.nix.tmp

      if grep -q '# GENERATED INPUTS START' flake.nix.tmp && grep -q '# GENERATED INPUTS END' flake.nix.tmp; then
        mv flake.nix.tmp flake.nix
      else
        echo "error: failed to regenerate flake inputs (missing markers in $flake_path)" >&2
        rm -f flake.nix.tmp
        exit 1
      fi
    '';

  unique = builtins.foldl' (acc: e: if builtins.elem e acc then acc else acc ++ [ e ]) [ ];
in
{
  inherit
    build
    generateInputs
    generateInputsPackage
    ;

  outputs =
    {
      inputs,
      settingsPath,
      modulesPath,
      nixpkgs ? inputs.nixpkgs,
      home-manager ? inputs.home-manager,
      extraSpecialArgs ? { },
      extraNixpkgs ? { },
    }:
    (build {
      inherit
        inputs
        settingsPath
        modulesPath
        nixpkgs
        home-manager
        extraSpecialArgs
        extraNixpkgs
        ;
    })
    // (
      let
        settings = import settingsPath;

        systems = unique (
          map (name: settings.systems.${name}.settings.system) (builtins.attrNames settings.systems)
        );

        packages = builtins.listToAttrs (
          map (
            system:
            let
              pkgs = import nixpkgs { inherit system; };
            in
            {
              name = system;
              value.generate-inputs = pkgs.callPackage generateInputsPackage {
                modulesDir = baseNameOf modulesPath;
              };
            }
          ) systems
        );
      in
      {
        inherit packages;
      }
    );
}
