{
  config,
  lib,
  hostName,
  myvars,
  pkgs,
  ...
}: let
  cfg = config.core';
in {
  options.core' = {
    hostName = lib.mkOption {
      type = lib.types.str;
      default = hostName;
      description = "NixOS 主机名";
    };

    timeZone = lib.mkOption {
      type = lib.types.str;
      default = myvars.timeZone;
      description = "系统时区";
    };

    hashedPassword = lib.mkOption {
      type = lib.types.str;
      default = myvars.hashedPassword;
      description = "主用户的密码哈希";
    };

    sshAuthorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = myvars.sshAuthorizedKeys;
      description = "主用户授权的 SSH 公钥";
    };
  };

  config = {
    users.users.${myvars.username} = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      hashedPassword = cfg.hashedPassword;
    };

    networking.hostName = cfg.hostName;
    time.timeZone = lib.mkDefault cfg.timeZone;

    # 把所有已知终端的 terminfo 数据库加入系统 profile
    environment.enableAllTerminfo = lib.mkDefault true;
    documentation.nixos.enable = lib.mkDefault false;

    # 服务器基础 CLI 工具
    environment.systemPackages = with pkgs; [
      btop
      curl
      fastfetch
      git
      just
      tmux
      vim
      wget
    ];
  };
}
