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
  };
}
