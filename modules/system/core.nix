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
      description = "NixOS host name";
    };

    timeZone = lib.mkOption {
      type = lib.types.str;
      default = myvars.timeZone;
      description = "System time zone";
    };

    hashedPassword = lib.mkOption {
      type = lib.types.str;
      default = myvars.hashedPassword;
      description = "Hashed password of the primary user";
    };

    sshAuthorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = myvars.sshAuthorizedKeys;
      description = "SSH keys authorized for the primary user";
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

    # Add the terminfo database of all known terminals to the system profile.
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
