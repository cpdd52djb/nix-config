{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.storage'.disko;

  btrfsContent = {
    type = "btrfs";
    extraArgs = [
      "-f"
      "--csum"
      "xxhash64"
      "--label"
      "NixOS"
    ];
    mountpoint = "/btr_pool";
    mountOptions = [
      "noatime"
      "subvolid=5"
    ];
    subvolumes = {
      "@nix" = {
        mountpoint = "/nix";
        mountOptions = [
          "compress=zstd:1"
          "discard=async"
          "noatime"
        ];
      };

      "@persistent" = {
        mountpoint = "/persistent";
        mountOptions = [
          "compress=zstd:1"
          "discard=async"
          "noatime"
        ];
      };

      "@root" = {
        mountpoint = "/";
        mountOptions = [
          "compress=zstd:1"
          "discard=async"
          "noatime"
        ];
      };

      "@snapshots" = {
        mountpoint = "/snapshots";
        mountOptions = [
          "compress=zstd:1"
          "discard=async"
          "noatime"
        ];
      };
    };
  };
in {
  imports = [inputs.disko.nixosModules.disko];

  options.storage'.disko = {
    enable = lib.mkEnableOption "Disko disk management";

    device = lib.mkOption {
      type = lib.types.str;
      example = "/dev/disk/by-id/nvme-example";
      description = "Disk device path";
    };

    espSize = lib.mkOption {
      type = lib.types.str;
      default = "1G";
      example = "512M";
      description = "EFI system partition size";
    };
  };

  config = lib.mkIf cfg.enable {
    disko.devices.disk.main = {
      type = "disk";
      device = cfg.device;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            size = cfg.espSize;
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              extraArgs = [
                "-n"
                "BOOT"
              ];
              mountOptions = ["umask=0077"];
            };
          };

          root = {
            priority = 2;
            size = "100%";
            type = "8300";
            content = btrfsContent;
          };
        };
      };
    };
  };
}
