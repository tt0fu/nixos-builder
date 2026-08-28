{
  home =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.btop ];
    };
}
