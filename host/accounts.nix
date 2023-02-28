{
  lib,
  pkgs,
  config,
  ...
}: let
  accounts = {
    inherit (config.users);
    inherit (config) home-manager security;
  };
in {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  security = {
    sudo.enable = false;
    doas.enable = true;
    doas.wheelNeedsPassword = false;
    pam.enableSSHAgentAuth = true;
  };

  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.oil;
    users.root.home = lib.mkForce "/admin/root";
    groups.admin.gid = 999;
    users.admin = {
      uid = 999;
      group = "admin";
      home = "/admin";
      description = "System Administrator";
      extraGroups = ["root" "wheel"];
      # initialPassword = "sysadmin";
    };
  };

  # services.fprintd.enable = true;
  # security.pam.services.login.fprintAuth = true;
  # security.pam.services.xlock.fprintAuth = true;
  # security.pam.services.xscreensaver.fprintAuth = true;
}
