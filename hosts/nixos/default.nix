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
  shells'.fish.enable = true;

  security'.firewall.enable = true;

  system.stateVersion = "26.05";
}
