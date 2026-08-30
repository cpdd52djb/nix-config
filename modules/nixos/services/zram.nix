{
  config,
  lib,
  ...
}: let
  cfg = config.services'.zram;
in {
  options.services'.zram = {
    enable = lib.mkEnableOption "compressed RAM swap with Zram";

    algorithm = lib.mkOption {
      type = lib.types.str;
      default = "zstd";
      description = "Compression algorithm used by Zram";
    };

    memoryPercent = lib.mkOption {
      type = lib.types.ints.between 1 100;
      default = 50;
      description = "Maximum Zram swap size as a percentage of system memory";
    };

    priority = lib.mkOption {
      type = lib.types.int;
      default = 100;
      description = "Swap priority for the Zram device";
    };
  };

  config = lib.mkIf cfg.enable {
    # Disable zswap to avoid putting a compressed cache in front of the
    # compressed Zram swap device.
    boot = {
      kernelParams = ["zswap.enabled=0"];
      kernel.sysctl."vm.swappiness" = 100;
      kernel.sysfs.module.zswap.parameters.enabled = false;
      zswap.enable = false;
    };

    zramSwap = {
      enable = true;
      inherit (cfg) algorithm memoryPercent priority;
    };
  };
}
