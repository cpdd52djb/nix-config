{pkgs, ...}: {
  imports = [
    ./hardware.nix
  ];

  services'.openssh = {
    enable = true;
    passwordAuthentication = true;
  };

  services'.mihomo = {
    enable = true;
    tunMode = true;
    webui = pkgs.zashboard;
  };

  services'.docker.enable = true;
  services'.nginx-proxy-manager.enable = true;

  tools'.mise.enable = true;
  tools'.dev.enable = true;
  shells'.fish.enable = true;

  desktop'.kde.enable = true;
  security'.firewall.enable = true;

  system.stateVersion = "26.05";
}
