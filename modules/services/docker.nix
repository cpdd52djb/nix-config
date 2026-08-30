{
  config,
  lib,
  myvars,
  ...
}: let
  cfg = config.services'.docker;
in {
  options.services'.docker = {
    enable = lib.mkEnableOption "Docker 容器引擎";
  };

  config = lib.mkIf cfg.enable {
    virtualisation = {
      podman.enable = false;
      oci-containers.backend = "docker";
      docker = {
        enable = true;
        enableOnBoot = true;
        storageDriver = "btrfs";

        autoPrune = {
          enable = true;
          dates = "weekly";
          flags = [
            "--all"
            "--filter=until=168h"
          ];
        };

        daemon.settings = {
          "live-restore" = true;
          # 宿主机 resolved 的 127.0.0.53 存根在容器里不可达，
          # docker 会回落到 8.8.8.8（国内不可靠），故显式指定
          dns = [
            "223.5.5.5"
            "119.29.29.29"
          ];
          "log-driver" = "local";
          "log-opts" = {
            "max-size" = "10m";
            "max-file" = "3";
          };
        };
      };

      # watchtower：每日 04:00 检查并自动更新所有容器（等价 podman 的 auto-update）
      oci-containers.containers.watchtower = {
        image = "docker.io/containrrr/watchtower:latest";
        autoStart = true;
        volumes = ["/var/run/docker.sock:/var/run/docker.sock"];
        environment = {
          TZ = "Asia/Shanghai";
          # 清理更新后留下的旧镜像
          WATCHTOWER_CLEANUP = "true";
          # 秒 分 时 日 月 周：每天 04:00
          WATCHTOWER_SCHEDULE = "0 0 4 * * *";
        };
      };
    };

    users.users.${myvars.username}.extraGroups = ["docker"];
  };
}
