{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tools'.dev;
in {
  options.tools'.dev = {
    enable = lib.mkEnableOption "开发用 CLI 工具集（direnv / gh / lazygit / uv 等）";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      alejandra
      deadnix
      nixd
    ];

    hm'.programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    hm'.home.packages = with pkgs; [
      gh
      lazygit
      uv
    ];

    # 工具集的运行时状态：gh 账号设置与凭证、direnv 白名单、
    # lazygit 最近仓库、uv 管理的解释器与工具。
    hm'.persist'.directories = [
      {
        directory = ".config/gh";
        mode = "0700";
      }
      ".local/share/direnv"
      ".local/state/lazygit"
      ".local/share/uv"
    ];
  };
}
