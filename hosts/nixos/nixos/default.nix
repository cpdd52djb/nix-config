{pkgs, ...}: {
  imports = [
    ./hardware.nix
  ];

  services' = {
    openssh = {
      enable = true;
      passwordAuthentication = true;
    };
    mihomo = {
      enable = true;
      tunMode = true;
      webui = pkgs.zashboard;
    };
  };

  services'.coder = {
    enable = true;
    listenAddress = "0.0.0.0:3000";
    accessUrl = "http://192.168.110.2:3000";
  };

  services'.postgresql.enable = true;

  desktop'.kde.enable = true;
  security'.firewall.enable = true;

  system.stateVersion = "26.05";
}
