{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.hardware'.nvidia;
in {
  options.hardware'.nvidia = {
    enable = lib.mkEnableOption "NVIDIA GPU support";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      # open 内核模块只支持 Turing 及更新的架构，Maxwell 必须用闭源模块
      open = false;
      modesetting.enable = true;
      nvidiaSettings = false;
      # 无桌面时保持驱动常驻初始化（以后跑 NVENC 转码也靠它）
      nvidiaPersistenced = true;
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    };

    environment.systemPackages = with pkgs; [
      nvtopPackages.nvidia
      pciutils
    ];
  };
}
