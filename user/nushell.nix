{
  lib,
  pkgs,
  config,
  ...
}: let 
  starship-nu-init = pkgs.runCommand "starship-init.nu" ''
    starship init nu > $out
  '';
in {
  home.packages = with pkgs; [
    carapace
  ];

  programs.nushell = {
    enable = true;
    extraEnv = ''
      mkdir ${config.xdg.cacheHome}/starship
      # starship init nu | save ${config.xdg.cacheHome}/starship/init.nu

      # let-env STARSHIP_SHELL = "nu"

      # def create_left_prompt [] {
      #     starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
      # }

      # let-env PROMPT_COMMAND = { create_left_prompt }
      # let-env PROMPT_COMMAND_RIGHT = ""
      # let-env PROMPT_INDICATOR = ""
    '';
    extraConfig = ''
      let carapace_completer = {|spans|
        carapace $spans.0 nushell $spans | from json
      }

      source ${config.xdg.cacheHome}/starship/init.nu
      # source $\{starship-nu-init}
    '';
  };

  programs.starship = {
    enable = true;
    # settings = {};
  };
}
