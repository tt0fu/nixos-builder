{
  description = "ttofu's nixos config builder";

  outputs =
    { ... }:
    {
      lib = import ./lib.nix;
      templates.default = {
        path = ./template;
        description = "An example nixos config flake that uses the builder";
      };
    };
}
