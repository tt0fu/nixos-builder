{
  os = { style, ... }: {
    console = {
      font = style.consoleFont;
      keyMap = "us";
      useXkbConfig = true; # use xkb.options in tty.
    };
  };
}
