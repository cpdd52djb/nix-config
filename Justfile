hostname := `hostname -s`

# 列出所有可用命令
default:
    @just --list

# 检查：格式化 + 死代码 + 全部主机求值
check:
    @alejandra --check .
    @deadnix --fail .
    @nix flake check path:. --no-build

# 格式化全部 Nix 文件
fmt:
    @nix fmt path:.

# 更新 flake.lock（nixpkgs / disko）
update:
    @nix flake update

# 更新锁文件并重建切换（一条龙）
upgrade:
    @nix flake update && just switch

# 只构建不切换（干跑，先看看这次会动什么）
build:
    @nh os build path:. -H {{ hostname }}

# 重建并切换当前系统
switch:
    @nh os switch path:. -H {{ hostname }}

# 重建并写入启动项（重启后生效）
boot:
    @nh os boot path:. -H {{ hostname }}

# 回滚到上一个系统 generation 并切换
rollback:
    @sudo nixos-rebuild --rollback switch

# 清理旧 generation 并回收 Nix Store 空间（交互确认）
gc:
    @nh clean all --keep 8 --keep-since 14d --ask

# 查看系统 generations 历史与 Nix Store 占用
history:
    @sudo nix profile history --profile /nix/var/nix/profiles/system
    @du -sh /nix/store
