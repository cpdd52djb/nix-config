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

  hardware'.nvidia.enable = true;

  boot = {
    # 最新主线内核；若 580 legacy 驱动对它编译失败，注释掉这行回退默认内核
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
    kernelModules = ["kvm-amd"];
    kernelParams = [
      "audit=0"
      "net.ifnames=0"
    ];
    extraModulePackages = [];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    tmp.cleanOnBoot = true;
  };

  storage'.disko = {
    enable = true;
    device = "/dev/nvme0n1";
    espSize = "1G";
  };

  services'.zram = {
    enable = true;
    priority = 5;
    algorithm = "zstd";
    memoryPercent = 100;
    memoryMax = 16 * 1024 * 1024 * 1024 + (1024 * 1024);
  };
}
