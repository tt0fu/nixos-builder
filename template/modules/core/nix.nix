{
  os =
    { ... }:
    {
      nix = {
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
        };
      };
      nixpkgs.config.allowUnfree = true;
    };
  home =
    { userSettings, ... }:
    {
      home = {
        username = userSettings.username;
        homeDirectory = "/home/" + userSettings.username;
        file = {
          ".config/nixpkgs/config.nix" = {
            text = ''
              {
                allowUnfree = true;
              }
            '';
          };
        };
      };
    };
}
