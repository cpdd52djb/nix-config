{
  config,
  lib,
  ...
}: let
  cfg = config.services'.zram;
in {
  options.services'.zram = {
    enable = lib.mkEnableOption "使用 zram 压缩内存作为 swap";

    algorithm = lib.mkOption {
      type = lib.types.str;
      default = "zstd";
      description = "zram 使用的压缩算法";
    };

    memoryPercent = lib.mkOption {
      type = lib.types.ints.positive;
      default = 50;
      description = "zram 可容纳的数据量上限，占总内存的百分比（可大于 100）";
    };

    memoryMax = lib.mkOption {
      type = with lib.types; nullOr int;
      default = null;
      example = lib.literalExpression "2 * 1024 * 1024 * 1024";
      description = "zram 可容纳的数据量上限（字节）；与 memoryPercent 同时设置时取较小者";
    };

    priority = lib.mkOption {
      type = lib.types.int;
      default = 5;
      description = "zram swap 的优先级，应高于磁盘 swap 以便优先使用 zram";
    };
  };

  config = lib.mkIf cfg.enable {
    # 关闭 zswap，避免在 zram 前再叠一层压缩缓存
    boot = {
      kernelParams = ["zswap.enabled=0"];
      kernel.sysctl."vm.swappiness" = 100;
      kernel.sysfs.module.zswap.parameters.enabled = false;
      zswap.enable = false;
    };

    zramSwap =
      {
        enable = true;
        inherit (cfg) algorithm memoryPercent priority;
      }
      // lib.optionalAttrs (cfg.memoryMax != null) {
        inherit (cfg) memoryMax;
      };
  };
}
