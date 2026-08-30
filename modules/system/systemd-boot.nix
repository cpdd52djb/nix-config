{
  config,
  lib,
  ...
}: let
  cfg = config.boot'.systemd-boot;
in {
  options.boot'.systemd-boot = {
    enable = lib.mkEnableOption "systemd-boot 引导";

    configurationLimit = lib.mkOption {
      type = lib.types.int;
      default = 8;
      description = "最多保留的历史启动项数量";
    };

    consoleMode = lib.mkOption {
      type = lib.types.enum ["0" "1" "2" "auto" "max" "keep"];
      default = "max";
      description = "启动菜单的控制台分辨率模式";
    };

    editor = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "是否允许在启动菜单中临时编辑内核参数（安全起见默认关闭）";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.loader.systemd-boot = {
      enable = true;
      inherit (cfg) configurationLimit consoleMode editor;
    };
  };
}
