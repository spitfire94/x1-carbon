{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.bootDevice;

  devTarg = label: "/dev/disk/by-partlabel/${cfg.id}-${label}";
  hostVol = label: "disk-${cfg.id}/${cfg.handle}/${label}";
  userVol = label: "disk-${cfg.id}/${cfg.owner}/${label}";

  serial-uuid = pkgs.runCommand "serial-uuid" {} ''
    ${pkgs.util-linux}/bin/uuidgen --sha1 --namespace @oid \
      --name ${cfg.serial} | tr -d "\n" > $out
  '';
  machine-id = pkgs.runCommand "machine-id" {} ''
    cat ${serial-uuid} | md5sum | head -c 8 > $out
  '';
  dev-id = pkgs.runCommand "dev-id" {} ''
    cat ${serial-uuid} | tail -c 6 > $out
  '';
in {
  options.bootDevice = {
    description = mkOption {
      default = "";
      description = "descriptive name of machine";
      type = types.str;
    };
    id = mkOption {
      type = types.str;
      description = "short idenifier";
      default = builtins.readFile dev-id;
      readOnly = true;
    };
    serial = mkOption {
      type = types.nullOr types.str;
      description = "hardware idenifier";
      default = null;
    };
    handle = mkOption {
      type = types.str;
      description = "primary host name";
      default = "";
    };
    owner = mkOption {
      type = types.nullOr types.str;
      description = "primary user name";
      default = null;
    };
    enableTrim = mkOption {
      type = types.bool;
      description = "enable discards if posible";
      default = true;
    };
    miscSize = mkOption {
      type = with types; either int str;
      description = "unalocated partition space";
      default = 2048;
    };
    bootSize = mkOption {
      type = with types; either int str;
      description = "size of boot partition";
      default = "1G";
    };
    stowSize = mkOption {
      type = with types; either int str;
      description = "size of stow partition";
      default = "2G";
    };
    swapSize = mkOption {
      type = with types; nullOr (either int str);
      description = "size of swap volume";
      default = null;
    };
    chassis = mkOption {
      default = null;
      description = "machine form factor";
      type = with types;
        enum [
          null
          "desktop"
          "laptop"
          "convertible"
          "server"
          "tablet"
          "jumper"
          "handset"
          "watch"
          "embedded"
          "vm"
          "container"
          "portable"
        ];
    };
  };

  config = {
    boot.initrd.luks.devices."bank-${cfg.id}" = {
      fallbackToPassword = mkDefault true;
      allowDiscards = cfg.enableTrim;
      device = devTarg "bank";
      preLVM = true;
    };

    fileSystems = {
      "/boot" = {
        device = devTarg "boot";
        fsType = "vfat";
      };
      "/boot/stow" = {
        device = devTarg "stow";
        fsType = "exfat";
      };
      "/" = {
        device = hostVol "rootfs";
        fsType = "zfs";
      };
      "/nix" = {
        device = hostVol "nix-store";
        fsType = "zfs";
      };
      "/tmp" = {
        device = hostVol "temporary";
        fsType = "zfs";
      };
      "/admin" = {
        device = hostVol "private";
        fsType = "zfs";
      };
      "/home" =
        mkIf (cfg.owner != null)
        {
          device = userVol "homedir";
          fsType = "zfs";
        };
      "/home/archive" =
        mkIf (cfg.owner != null)
        {
          device = userVol "archive";
          fsType = "zfs";
        };
      "/home/media" =
        mkIf (cfg.owner != null)
        {
          device = userVol "media";
          fsType = "zfs";
        };
    };

    boot.resumeDevice =
      mkIf (cfg.swapSize != null)
      "/dev/disk/by-label/swap-${cfg.id}";
    swapDevices = mkIf (cfg.swapSize != null) [
      {
        label = "swap-" + cfg.id;
        device = "/dev/disk/by-label/swap-${cfg.id}";
        discardPolicy = mkIf (cfg.enableTrim) "once";
        encrypted.label = "bank-" + cfg.id;
        encrypted.blkDev = devTarg "bank";
        encrypted.enable = true;
        priority = 5;
      }
    ];

    boot.loader.grub = {
      enable = true;
      version = 2;
      device = "nodev";
      zfsSupport = true;
      efiSupport = true;
      fsIdentifier = "label";
      enableCryptodisk = true;
      efiInstallAsRemovable = true;
      extraEntries = ''
        menuentry "Reboot" {
          reboot
        }
        menuentry "Poweroff" {
          halt
        }
      '';
    };

    boot.initrd.luks.yubikeySupport = true;
    boot.loader.efi.canTouchEfiVariables = false;
    boot.supportedFilesystems = ["zfs" "exfat" "btrfs" "f2fs" "xfs" "ntfs"];
    hardware.cpu.intel.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;
    networking.hostId = builtins.readFile machine-id;
    networking.hostName = cfg.handle;
  };
}
