{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # NVIDIA GTX 950（Maxwell）：580 是最后一个支持该架构的驱动分支
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # open 内核模块只支持 Turing 及更新的架构，Maxwell 必须用闭源模块
    open = false;
    modesetting.enable = true;
    nvidiaSettings = false;
    # 无桌面时保持驱动常驻初始化（以后跑 NVENC 转码也靠它）
    nvidiaPersistenced = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
    pciutils
  ];

  boot = {
    # 最新主线内核；若 580 legacy 驱动对它编译失败，注释掉这行回退默认内核
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 8;
        editor = false;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
    };

    tmp.cleanOnBoot = true;

    kernelParams = [
      "audit=0"
      "net.ifnames=0"
      "zswap.enabled=0"
    ];
    kernel.sysctl."vm.swappiness" = 100;
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };
}
