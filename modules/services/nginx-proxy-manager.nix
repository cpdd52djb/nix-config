{
  config,
  lib,
  ...
}: let
  cfg = config.services'.nginx-proxy-manager;
in {
  options.services'.nginx-proxy-manager = {
    enable = lib.mkEnableOption "Nginx Proxy Manager 反向代理管理面板（容器）";

    image = lib.mkOption {
      type = lib.types.str;
      default = "docker.io/jc21/nginx-proxy-manager:latest";
      description = "NPM 容器镜像（写全限定名，不依赖默认仓库配置）";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/nginx-proxy-manager";
      description = "宿主机数据目录（配置与证书），持久落盘";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.nginx-proxy-manager = {
      inherit (cfg) image;
      autoStart = true;

      # 自动更新由 docker.nix 里的 watchtower 负责

      ports = [
        "80:80" # HTTP
        "443:443" # HTTPS
        "81:81" # 管理面板
      ];

      volumes = [
        "${cfg.dataDir}/data:/data"
        "${cfg.dataDir}/letsencrypt:/etc/letsencrypt"
      ];
    };

    # 提前建好数据目录，避免容器以 root 启动时自动创建权限不可控
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}/data 0750 root root - -"
      "d ${cfg.dataDir}/letsencrypt 0750 root root - -"
    ];

    networking.firewall.allowedTCPPorts = [80 81 443];
  };
}
