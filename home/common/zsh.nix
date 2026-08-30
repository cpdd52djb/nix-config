{
  programs.zsh = {
    enable = true;
    initContent = ''
      # 开发工具集启用时加载 uv / uvx 补全。
      if command -v uv &>/dev/null; then
        eval "$(uv generate-shell-completion zsh)"
      fi

      if command -v uvx &>/dev/null; then
        eval "$(uvx --generate-shell-completion zsh)"
      fi
    '';
  };
}
