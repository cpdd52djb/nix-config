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
    enable = lib.mkEnableOption "PostgreSQL service";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.postgresql_18;
      description = "PostgreSQL package to use";
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
        # Let other names login as themselves
        superuser_map      /^(.*)$    \1
      '';

      initdbArgs = [
        "--data-checksums"
        "--allow-group-access"
      ];

      # https://www.postgresql.org/docs/current/auth-pg-hba-conf.html
      authentication = ''
        # TYPE  DATABASE        USER            ADDRESS                 METHOD   OPTIONS

        # "local" is for Unix domain socket connections only
        local   all             all                                     peer     map=superuser_map

        # Replication connections from localhost
        local   replication     all                                     peer     map=superuser_map

        # 远程访问默认关闭；需要时打开 enableTCPIP 并按网段放开：
        # host    all             all             192.168.110.0/24        scram-sha-256
      '';
    };
  };
}
