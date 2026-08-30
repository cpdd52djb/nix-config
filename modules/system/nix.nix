{
  inputs,
  lib,
  myvars,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  nix = {
    # 已使用 flakes，移除 channel 相关工具与配置
    channel.enable = false;

    optimise.automatic = true;

    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;

      # SJTU 镜像优先，官方缓存兜底（签名密钥相同，无需额外 trusted key）
      substituters = [
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
      ];

      trusted-users = [myvars.username];
    };

    registry.nixpkgs.flake = inputs.nixpkgs;

    gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 14d";
    };
  };

  programs.nh = {
    enable = true;
    flake = lib.mkDefault "/home/${myvars.username}/nix-config";
  };
}
