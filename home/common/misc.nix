{
  lib,
  pkgs,
  ...
}: {
  home.packages = lib.mkAfter (with pkgs; [
    # 开发
    just

    # 磁盘与清理
    duf
    dust

    # 文件与搜索
    fd
    fzf
    jq
    ripgrep
    wget

    # 网络
    iperf3
    nmap
    socat

    # 系统监控
    btop
    fastfetch
    nload
  ]);

  # btop 在 UI 里修改设置时会重写配置文件。
  persist'.directories = [
    ".config/btop"
  ];
}
