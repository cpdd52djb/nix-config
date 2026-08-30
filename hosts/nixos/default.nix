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

  desktop'.kde.enable = true;
  security'.firewall.enable = true;

  system.stateVersion = "26.05";
}
