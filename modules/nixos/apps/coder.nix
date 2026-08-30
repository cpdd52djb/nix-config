{
  config,
  lib,
  ...
}: let
  cfg = config.services'.coder;

  # The upstream option is a "host:port" string; the port is always the
  # segment after the last colon.
  listenPort = lib.toInt (lib.last (lib.splitString ":" cfg.listenAddress));

  loopbackListen =
    lib.hasPrefix "127." cfg.listenAddress
    || lib.hasPrefix "localhost" cfg.listenAddress
    || lib.hasPrefix "[::1]" cfg.listenAddress;
in {
  options.services'.coder = {
    enable = lib.mkEnableOption "Coder server";

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1:3000";
      description = "Address and port the Coder server listens on; use 0.0.0.0:3000 for direct LAN access";
    };

    accessUrl = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "https://coder.example.com";
      description = "External URL users use to reach Coder; required for workspace apps and port forwarding";
    };
  };

  config = lib.mkIf cfg.enable {
    services.coder = {
      enable = true;
      listenAddress = lib.mkDefault cfg.listenAddress;
      accessUrl = lib.mkDefault cfg.accessUrl;
      environment.extra.CODER_TELEMETRY = "false";
    };

    # The upstream unit only orders after network.target, which races with
    # PostgreSQL init on first boot.
    systemd.services.coder = {
      after = ["postgresql.service"];
      requires = ["postgresql.service"];
    };

    networking.firewall.allowedTCPPorts = [listenPort];

    warnings =
      lib.optional
      loopbackListen
      "services'.coder is enabled with listenAddress ${cfg.listenAddress} on loopback; external clients cannot reach Coder";
  };
}
