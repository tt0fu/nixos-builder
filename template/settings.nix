{
  userSettings = {
    username = "ttofu";
  };

  baseStyle = {
    consoleFont = "Lat2-Terminus16";
  };

  systems = {
    nixos = {
      settings = {
        system = "x86_64-linux";
        timeZone = "Europe/London";
        locale = "en_US.UTF-8";
      };
      modules =
        modules: with modules; [
          systems.nixos
          core
          programs.essential
          programs.utils
          programs.misc
        ];
    };
  };
}
