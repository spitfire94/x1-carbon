{
  lib,
  pkgs,
  config,
  ...
}: {
  home.shellAliases = {
    "..." = "cd ../..";
    "ed" = "$EDITOR";
    "ve" = "$VISUAL";
    "pg" = "$PAGER";
    "ls" = "exa -F";
    "la" = "exa -Fa --long --git";
    "ll" = "exa -F --long --git-ignore --sort=modified";
    "lt" = "exa -Fa --long --git --git-ignore -I '.git*' --tree";
    "cat" = "bat";
    "mkd" = "mkdir -p";
    "mkf" = "touch";
    "del" = "rm -I";
    "lnk" = "ln -s";
    "lnr" = "ln -rs";
    "rmf" = "rm -rf";
    "clr" = "reset; clear";
    "mnt" = "doas mount --mkdir";
    "ejc" = "doas umount --quiet --recursive";
    "mnt.zfs" = "mnt -t zfs";
    "rlsh" = "exec $SHELL";
    "sudo" = "doas";
    "redoas" = "doas !!";
    "dt-stmp" = "date --utc +%Y%m%d%H%M%S";
    "nixos-rb" = "doas nixos-rebuild boot --flake $NIXOS_CONFIG#";
    "nixos-sw" = "doas nixos-rebuild switch --flake $NIXOS_CONFIG#";
    "wake-lock" = "systemd-inhibit --why='Allow long running command to finish' --what=idle:sleep:handle-lid-switch --";
    "sync-copy" = "wake-lock rsync -ah --partial --no-inc-recursive --info=progress2";
    "nixos-build" = "nom build $NIXOS_CONFIG#nixosConfigurations.$HOSTNAME.config.system.build.toplevel && doas nixos-rebuild boot --flake $NIXOS_CONFIG#";
  };
}