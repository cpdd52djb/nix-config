{
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    settings = {
      sync_frequency = 0;
      inline_height = 30;
      history_filter = [
        ''^ls($|(\s+((-([a-zA-Z0-9]|-)+)|"(\.|[^/])[^"]*"|'(\.|[^/])[^']*'|(\.|[^/\s-])[^\s]*))*\s*$)'' # 过滤非绝对路径的 ls 命令
        ''^cd($|\s+('[^/][^']*'|"[^/][^"]*"|[^/\s'"][^\s]*))$'' # 过滤非绝对路径的 cd 命令
        "/nix/store/.*" # 包含 /nix/store 的命令
        ''--cookie[=\s]+.+'' # 包含 cookie 的命令
      ];
    };
  };

  persist'.directories = [
    {
      directory = ".atuin";
      mode = "0700";
    }
    ".local/share/atuin"
  ];
}
