{
  config,
  lib,
  ...
}: let
  cfg = config.services'.btrfs-scrub;
in {
  options.services'.btrfs-scrub = {
    enable = lib.mkEnableOption "每月定时校验 Btrfs 文件系统数据";

    interval = lib.mkOption {
      type = lib.types.str;
      # 定在每月 1 日 04:00，避开整点高负载时段
      default = "*-*-01 04:00:00";
      description = "控制校验频率的 systemd calendar 时间表达式";
    };
  };

  config = lib.mkIf cfg.enable {
    services.btrfs.autoScrub = {
      enable = true;
      inherit (cfg) interval;
    };
  };
}
