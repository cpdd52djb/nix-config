{
  config,
  lib,
  ...
}: let
  cfg = config.security'.firewall;
in {
  options.security'.firewall = {
    enable = lib.mkEnableOption "Firewall with nftables";
  };

  config = {
    # 有线直插：systemd-networkd 对 eth0 DHCP，不用 NetworkManager
    networking.useNetworkd = true;

    networking.firewall = lib.mkIf cfg.enable {
      enable = true;
      allowPing = true;
    };
    networking.nftables.enable = cfg.enable;

    systemd.network = {
      enable = true;
      networks."10-wired" = {
        matchConfig.Name = "eth0";
        networkConfig.DHCP = "yes";
        linkConfig.RequiredForOnline = "routable";
      };
    };

    services.resolved.enable = true;
  };
}
