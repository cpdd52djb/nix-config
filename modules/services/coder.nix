{
  config,
  lib,
  ...
}: let
  cfg = config.services'.coder;

  # 上游选项是 "host:port" 字符串；端口永远取最后一个冒号之后的段落。
  listenPort = lib.toInt (lib.last (lib.splitString ":" cfg.listenAddress));

  loopbackListen =
    lib.hasPrefix "127." cfg.listenAddress
    || lib.hasPrefix "localhost" cfg.listenAddress
    || lib.hasPrefix "[::1]" cfg.listenAddress;
in {
  options.services'.coder = {
    enable = lib.mkEnableOption "Coder 开发工作区服务";

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1:3000";
      description = "Coder 服务监听的地址与端口；局域网直连用 0.0.0.0:3000";
    };

    accessUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "https://coder.example.com";
      description = "用户访问 Coder 的外部 URL；workspace 应用与端口转发依赖它";
    };
  };

  config = lib.mkIf cfg.enable {
    services.coder = {
      enable = true;
      listenAddress = lib.mkDefault cfg.listenAddress;
      accessUrl = lib.mkDefault cfg.accessUrl;
      environment.extra.CODER_TELEMETRY = "false";
    };

    # 上游 unit 只 after network.target，与 PostgreSQL 首次初始化存在竞态
    systemd.services.coder = {
      after = ["postgresql.service"];
      requires = ["postgresql.service"];
    };

    networking.firewall.allowedTCPPorts = [listenPort];

    warnings =
      lib.optional
      loopbackListen
      "services'.coder 已启用，但 listenAddress ${cfg.listenAddress} 只监听回环地址，外部客户端无法访问";
  };
}
