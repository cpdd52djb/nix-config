{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.tools'.mise;
in {
  options.tools'.mise = {
    enable = lib.mkEnableOption "mise 多运行时版本管理器（node / python / go 等）";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.mise];

    # 在主用户的 fish 交互 shell 中激活 mise（经 hm' 走 Home Manager）；
    # 换其他 shell 时改成对应 activate 参数
    hm'.programs.fish.interactiveShellInit = ''
      ${lib.getExe pkgs.mise} activate fish | source
    '';

    # mise 下载的预编译工具链是动态链接的，NixOS 需要加载器兜底；
    # 运行时缺库报错时往 libraries 里追加对应包即可
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib
        zlib
        openssl
        curl
        libffi
      ];
    };
  };
}
