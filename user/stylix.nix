{
  lib,
  pkgs,
  config,
  ...
}: {
  stylix = {
    image = ./wallpaper/wp-01.png;
    polarity = "dark";
	targets.vscode.enable = false;
  };
}
