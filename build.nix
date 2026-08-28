{
  inputs,
  settingsPath,
  modulesPath,
  nixpkgs ? inputs.nixpkgs,
  home-manager ? inputs.home-manager,
  extraSpecialArgs ? { },
  extraNixpkgs ? { },
}:
let
  inherit (import ./modules.nix)
    loadModules
    expandModules
    resolveDeps
    collectOS
    collectHome
    ;

  allModules = loadModules modulesPath;

  settings = import settingsPath;

  userSettings = settings.userSettings;
in
{
  nixosConfigurations = builtins.mapAttrs (
    name: curSystem:
    let
      systemSettings = curSystem.settings // {
        hostname = name;
      };

      system = systemSettings.system;

      extraNikpkgsSpecialArgs = builtins.mapAttrs (
        name: value: (import value { inherit system; })
      ) extraNixpkgs;

      style = nixpkgs.lib.recursiveUpdate settings.baseStyle (curSystem.styleOverrides or { });

      usedModules = resolveDeps allModules (expandModules (curSystem.modules allModules));

      specialArgs = {
        inherit
          inputs
          systemSettings
          userSettings
          style
          allModules
          usedModules
          ;
      }
      // extraSpecialArgs
      // extraNikpkgsSpecialArgs;

      modules = (collectOS usedModules) ++ [
        home-manager.nixosModules.default
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = specialArgs;
            users.${userSettings.username} =
              { ... }:
              {
                imports = (collectHome usedModules);
              };
          };
        }
      ];
    in
    nixpkgs.lib.nixosSystem {
      inherit system specialArgs modules;
    }
  ) settings.systems;
}
