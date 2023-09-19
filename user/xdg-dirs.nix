{
  lib,
  pkgs,
  config,
  ...
}: let
  myhome = config.home.homeDirectory;
in {
  programs.gpg.homedir = lib.mkDefault "${config.xdg.stateHome}/gnupg";
  xdg = {
    enable = true;
    configHome = "${myhome}/.local/config";
    cacheHome = "${myhome}/.local/cache";
    stateHome = "${myhome}/.local/state";
    dataHome = "${myhome}/.local/share";
    userDirs = {
      enable = true;
      createDirectories = lib.mkDefault true;
      pictures = "${myhome}/media/image";
      videos = "${myhome}/media/video";
      music = "${myhome}/media/audio";
      desktop = "${myhome}/surface";
      download = "${myhome}/deposit";
      documents = "${myhome}/records";
      publicShare = "${myhome}/transit";
      templates = "${myhome}/records/templates";
      extraConfig = {
        XDG_SMUT_DIR = "${myhome}/media/porno";
        XDG_BOOK_DIR = "${myhome}/media/ebook";
        XDG_MISC_DIR = "${myhome}/media/other";
        XDG_PROJ_DIR = "${myhome}/project";
        XDG_WORK_DIR = "${myhome}/clients";
        XDG_ARCH_DIR = "${myhome}/archive";
        XDG_BACKUP_DIR = "${myhome}/backups";
        XDG_BIN_DIR = "${myhome}/.local/bin";
      };
    };
  };
}
