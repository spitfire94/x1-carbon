{
  lib,
  pkgs,
  config,
  ...
}: let 
  badge = import ./badge.nix;
in{
  security.pam.services."${badge.handle}".yubicoAuth = true;
  home-manager.users."${badge.handle}" = import ./abode.nix;
  users.extraGroups."${badge.handle}".gid = 909;
  users.extraUsers."${badge.handle}" = {
    description = badge.realname;
    uid = 909;
    home = "/home";
    shell = pkgs.nushell;
    group = badge.handle;
    hashedPassword = lib.readFile ./pwdhash.txt;
    extraGroups = [
      "admin"
      "wheel"
      "users"
      "systemd-journal"
      "networkmanager"
      "disk"
      "audio"
      "video"
      "adbusers"
      "uucp"
      "input"
      "vboxusers"
    ];
  };
}
