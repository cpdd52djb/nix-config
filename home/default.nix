{
  lib,
  myvars,
  ...
}: let
  modules =
    builtins.filter
    (path: lib.hasSuffix ".nix" (toString path))
    (lib.filesystem.listFilesRecursive ./common);
in {
  imports = modules;

  home = {
    username = myvars.username;
    homeDirectory = "/home/${myvars.username}";
    stateVersion = "26.05";
  };

  # 需要二次 switch 才能跳过选项手册的构建，仅关 man.enable 不够。
  programs.man.enable = false;
  manual.manpages.enable = false;
}
