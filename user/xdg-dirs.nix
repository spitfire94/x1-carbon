{
  lib,
  pkgs,
  config,
  ...
}: let
  home = config.home.homeDirectory;
in {
  programs.gpg.homedir = lib.mkDefault "${config.xdg.stateHome}/gnupg";
  xdg = {
    enable = true;
    configHome = "${home}/.local/config";
    cacheHome = "${home}/.local/cache";
    stateHome = "${home}/.local/state";
    dataHome = "${home}/.local/share";
    userDirs = {
      enable = true;
      createDirectories = lib.mkDefault true;
      pictures = "${home}/media/image";
      videos = "${home}/media/video";
      music = "${home}/media/audio";
      desktop = "${home}/surface";
      download = "${home}/deposit";
      documents = "${home}/records";
      publicShare = "${home}/transit";
      templates = "${home}/records/templates";
      extraConfig = {
        XDG_SMUT_DIR = "${home}/media/porno";
        XDG_BOOK_DIR = "${home}/media/ebook";
        XDG_MISC_DIR = "${home}/media/other";
        XDG_PROJ_DIR = "${home}/project";
        XDG_WORK_DIR = "${home}/clients";
        XDG_ARCH_DIR = "${home}/archive";
        XDG_BACKUP_DIR = "${home}/backups";
        XDG_BIN_DIR = "${home}/.local/bin";
      };
    };
  };
}
