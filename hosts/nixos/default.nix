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

  tools'.mise.enable = true;
  tools'.dev.enable = true;
  tools'.coding-agents.enable = true;
  shells'.fish.enable = true;

  desktop'.kde.enable = true;
  security'.firewall.enable = true;

  system.stateVersion = "26.05";
}
