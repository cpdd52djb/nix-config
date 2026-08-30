{
  config,
  lib,
  myvars,
  pkgs,
  ...
}: let
  cfg = config.shells'.fish;
in {
  options.shells'.fish = {
    enable = lib.mkEnableOption "fish shell 并设为主用户默认登录 shell";

    viKeyBindings = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "fish 使用 vi 模式键位";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.fish = {
      enable = true;
      useBabelfish = true;
      shellInit = lib.optionalString cfg.viKeyBindings ''
        fish_vi_key_bindings
      '';
    };

    users.users.${myvars.username}.shell = pkgs.fish;
  };
}
