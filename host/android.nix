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
    android-tools
    android-udev-rules
    android-file-transfer
    # android-backup-extractor
    # payload-dumper-go
    # imgpatchtools
    # f2fs-tools
    # e2fsprogs
    # abootimg
    # sdat2img
    # simg2img
    # tar2ext4
    # waydroid
    # scrcpy
    # parted
    mtpfs
  ];
}
