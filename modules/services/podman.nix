{
  config,
  lib,
  myvars,
  ...
}: let
  cfg = config.services'.podman;
in {
  options.services'.podman = {
    enable = lib.mkEnableOption "Podman 容器引擎";
  };

  config = lib.mkIf cfg.enable {
    virtualisation = {
      docker.enable = false;
      oci-containers.backend = "podman";

      # 手动 podman run 短镜像名时默认去 docker.io 拉（容器内已写全限定名，不受此项影响）
      containers.registries.search = ["docker.io"];

      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;

        autoPrune = {
          enable = true;
          dates = "weekly";
          flags = [
            "--all"
            "--filter=until=168h"
          ];
        };
      };

      containers.containersConf.settings.containers = {
        log_driver = "journald";
      };
    };

    # 容器声明 io.containers.autoupdate=registry 标签即可参与自动更新
    systemd.timers.podman-auto-update.wantedBy = ["timers.target"];

    users.users.${myvars.username}.extraGroups = ["podman"];
  };
}
