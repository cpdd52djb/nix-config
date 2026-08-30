{lib, ...}: let
  # 递归收集目录下的 .nix 模块；子目录含 default.nix 时按单模块整体导入
  listModules = directory:
    lib.pipe (builtins.readDir directory) [
      (lib.mapAttrsToList (
        name: type: let
          path = directory + "/${name}";
          isNixDirectory = builtins.pathExists (path + "/default.nix");
          isNixFile = type == "regular" && lib.hasSuffix ".nix" name;
        in
          if type == "directory"
          then
            if isNixDirectory
            then [path]
            else listModules path
          else lib.optional isNixFile path
      ))
      lib.flatten
    ];

  # 扫描所有子目录，根目录自身（default.nix）不在扫描范围
  subDirectories = lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./.);
in {
  imports = lib.flatten (
    lib.mapAttrsToList (name: _: listModules (./. + "/${name}")) subDirectories
  );
}
