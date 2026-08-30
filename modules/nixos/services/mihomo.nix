{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services'.mihomo;
in {
  options.services'.mihomo = {
    enable = lib.mkEnableOption "Mihomo proxy daemon";

    configFile = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/mihomo/config.yaml";
      description = "Path to the Mihomo config file (contains subscription secrets; keep out of git and /nix/store)";
    };

    tunMode = lib.mkEnableOption "kernel capabilities required by TUN mode (also enable tun in the Mihomo config)";

    webui = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      example = "pkgs.zashboard";
      description = "Dashboard package served by Mihomo at /ui via the external controller";
    };

    webuiPort = lib.mkOption {
      type = lib.types.port;
      default = 9090;
      description = "TCP port of the external controller; must match external-controller in the Mihomo config";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mihomo = {
      enable = true;
      inherit (cfg) configFile tunMode webui;
    };

    environment.systemPackages = [pkgs.mihomo];

    networking.firewall.allowedTCPPorts = lib.mkIf (cfg.webui != null) [cfg.webuiPort];
  };
}
