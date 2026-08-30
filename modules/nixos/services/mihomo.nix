{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services'.mihomo;
in {
  options.services'.mihomo = {
    enable = lib.mkEnableOption "Mihomo 代理服务";

    configFile = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/mihomo/config.yaml";
      description = "Mihomo 配置文件路径（含订阅密钥，勿提交进 git 与 /nix/store）";
    };

    tunMode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "是否为 TUN 模式授予所需内核能力（还需在 Mihomo 配置里启用 tun）";
    };

    webui = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      example = "pkgs.zashboard";
      description = "由 Mihomo 经外部控制器在 /ui 路径托管的仪表面板软件包";
    };

    webuiPort = lib.mkOption {
      type = lib.types.port;
      default = 9090;
      description = "外部控制器 TCP 端口，需与 Mihomo 配置中的 external-controller 一致";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mihomo = {
      enable = true;
      inherit (cfg) configFile tunMode webui;
    };

    environment.systemPackages = [pkgs.mihomo];

    networking.firewall.allowedTCPPorts = lib.mkIf (cfg.webui != null) [cfg.webuiPort];
  };
}
