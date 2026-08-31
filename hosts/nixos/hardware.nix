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

  hardware'.nvidia.enable = true;
  boot'.systemd-boot.enable = true;

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
    kernelModules = ["kvm-amd"];
    kernelParams = [
      "audit=0"
      "net.ifnames=0"
    ];
    extraModulePackages = [];

    loader.efi.canTouchEfiVariables = true;

    tmp.cleanOnBoot = true;
  };

  storage'.disko = {
    enable = true;
    device = "/dev/sda";
    espSize = "256M";
  };

  services'.smartd.enable = true;
  services'.btrfs-scrub.enable = true;

  services'.zram = {
    enable = true;
    priority = 5;
    algorithm = "zstd";
    memoryPercent = 100;
    memoryMax = 16 * 1024 * 1024 * 1024 + (1024 * 1024);
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
