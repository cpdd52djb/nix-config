{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # 关闭欢迎语。
      set -g fish_greeting

      # 开发工具集启用时加载 uv / uvx 补全。
      if command -q uv
        uv generate-shell-completion fish | source
      end

      if command -q uvx
        uvx --generate-shell-completion fish | source
      end
    '';
  };
}
