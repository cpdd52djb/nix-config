{
  config,
  lib,
  ...
}: let
  cfg = config.services'.openssh;
in {
  options.services'.openssh = {
    enable = lib.mkEnableOption "OpenSSH 守护进程";

    port = lib.mkOption {
      type = lib.types.port;
      default = 22;
      description = "OpenSSH 监听的 TCP 端口";
    };

    passwordAuthentication = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "是否允许密码登录";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "是否在防火墙中放行 SSH 端口";
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [cfg.port];
      settings = {
        PermitRootLogin = lib.mkDefault "no";
        PasswordAuthentication = lib.mkDefault cfg.passwordAuthentication;
      };
      openFirewall = cfg.openFirewall;
    };
  };
}
