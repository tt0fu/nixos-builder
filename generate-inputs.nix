{
  modulesPath,
  flakePath ? null,
}:
let
  inherit (import ./modules.nix) collectInputs;

  inputs = collectInputs modulesPath;

  indent = n: builtins.concatStringsSep "" (builtins.genList (_: "  ") n);

  escapeString =
    s:
    let
      len = builtins.stringLength s;

      go =
        i:
        if i >= len then
          ""
        else
          let
            c = builtins.substring i 1 s;
            next = builtins.substring i 2 s;
          in
          if c == "\\" then
            "\\\\" + go (i + 1)
          else if c == "\"" then
            "\\\"" + go (i + 1)
          else if c == "\n" then
            "\\n" + go (i + 1)
          else if c == "\t" then
            "\\t" + go (i + 1)
          else if next == "\${" then
            "\\\${" + go (i + 2)
          else
            c + go (i + 1);
    in
    "\"" + go 0 + "\"";

  toNix =
    level: v:
    if builtins.isString v then
      escapeString v
    else if builtins.isInt v then
      toString v
    else if builtins.isBool v then
      (if v then "true" else "false")
    else if v == null then
      "null"
    else if builtins.isList v then
      "[ " + (builtins.concatStringsSep " " (map (toNix 0) v)) + " ]"
    else if builtins.isAttrs v then
      "{\n"
      + (builtins.concatStringsSep "" (
        map (n: "${indent level}${n} = ${toNix (level + 1) v.${n}};\n") (builtins.attrNames v)
      ))
      + indent (level - 1)
      + "}"
    else
      throw "generate-inputs: cannot serialize flake input value of type ${builtins.typeOf v}";

  generatedInputs = builtins.concatStringsSep "" (
    map (name: "    ${name} = ${toNix 3 inputs.${name}};\n") (builtins.attrNames inputs)
  );

  startMarker = "# GENERATED INPUTS START";
  endMarker = "# GENERATED INPUTS END";

  splitFirst =
    sep: s:
    let
      parts = builtins.split "(${sep})" s;
    in
    if builtins.length parts == 1 then
      {
        before = s;
        after = null;
      }
    else
      {
        before = builtins.elemAt parts 0;
        after = builtins.elemAt parts 2;
      };

  newFlake =
    if flakePath == null then
      null
    else
      let
        text = builtins.readFile flakePath;
        first = splitFirst startMarker text;
        second = if first.after == null then { after = null; } else splitFirst endMarker first.after;
      in
      if first.after == null || second.after == null then
        throw "generate-inputs.nix: flake.nix is missing the '# GENERATED INPUTS START' / '# GENERATED INPUTS END' markers"
      else
        first.before
        + startMarker
        + "\n"
        + generatedInputs
        + builtins.head (builtins.match ".*\n([ \t]*)$" second.before)
        + endMarker
        + second.after;
in
{
  inherit inputs generatedInputs newFlake;
}
