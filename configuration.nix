{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware.nix
  ];

  networking.useNetworkd = true;
  networking.firewall = {
    enable = true;
    allowPing = true;
  };
  systemd.network = {
    enable = true;
    networks."10-wired" = {
      matchConfig.Name = "en* eth*";
      networkConfig.DHCP = "yes";
      linkConfig.RequiredForOnline = "routable";
    };
  };
  services.resolved.enable = true;

  time.timeZone = "Asia/Shanghai";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocales = ["zh_CN.UTF-8/UTF-8"];
  };

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
      substituters = [
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
      ];
    };
    registry.nixpkgs.flake = inputs.nixpkgs;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
  nixpkgs.config.allowUnfree = true;

  programs.nh = {
    enable = true;
    flake = "/home/cai/nix-config";
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users.cai = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    hashedPassword = "$y$j9T$fXIHIyb1usprTzAw.ntqJ/$I/sbwudS.KESDGLwKV8QzsLqr7pNQvYYv20GcWKFsV1";
  };

  environment = {
    enableAllTerminfo = true;
    systemPackages = with pkgs; [
      btop
      curl
      git
      tmux
      vim
      wget
      fastfetch
      just
      mihomo
    ];
  };
  documentation.nixos.enable = false;

  services.btrfs.autoScrub = {
    enable = true;
    interval = "*-*-01 04:00:00";
  };
  services.smartd.enable = true;

  services.mihomo = {
    enable = true;
    configFile = "/var/lib/mihomo/config.yaml";
  };

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  system.stateVersion = "26.05";
}
