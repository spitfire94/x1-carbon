{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.programs.nushell;
in{
  imports = [
    # inputs.home-mgr.nixosModules.default
  ];
  
  options.programs.nushell = {};
  
  config = lib.mkIf cfg.enable {};
}