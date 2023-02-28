{
  lib,
  pkgs,
  config,
  ...
}: {
  programs.adb.enable = true;
  nixpkgs.config.android_sdk.accept_license = true;
  users.users.admin.extraGroups = ["adbusers"];
  environment.systemPackages = with pkgs; [
    android-udev-rules
    android-file-transfer
  ];
}
