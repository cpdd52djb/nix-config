{
  config,
  lib,
  myvars,
  pkgs,
  ...
}: let
  cfg = config.services'.postgresql;
in {
  options.services'.postgresql = {
    enable = lib.mkEnableOption "PostgreSQL 数据库服务";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.postgresql_18;
      description = "使用的 PostgreSQL 软件包";
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      inherit (cfg) package;
      enableJIT = true;

      settings = {
        max_connections = 100;
        log_connections = true;
        log_statement = "ddl";
        log_disconnections = true;
        shared_buffers = "128MB";
        huge_pages = "try";
      };

      identMap = ''
        superuser_map      root       postgres
        superuser_map      postgres   postgres
        superuser_map      ${myvars.username}   postgres
        # 其余系统用户以同名身份登录
        superuser_map      /^(.*)$    \1
      '';

      initdbArgs = [
        "--data-checksums"
        "--allow-group-access"
      ];

      # https://www.postgresql.org/docs/current/auth-pg-hba-conf.html
      authentication = ''
        # 类型    数据库          用户            地址                    认证方式  选项

        # 本地 Unix domain socket 连接
        local   all             all                                     peer     map=superuser_map

        # 来自本机的复制连接
        local   replication     all                                     peer     map=superuser_map

        # 远程访问默认关闭；需要时打开 enableTCPIP 并按网段放开：
        # host    all             all             192.168.110.0/24        scram-sha-256
      '';
    };
  };
}
