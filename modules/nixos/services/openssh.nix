{
  config,
  lib,
  ...
}: let
  cfg = config.services'.openssh;
in {
  options.services'.openssh = {
    enable = lib.mkEnableOption "OpenSSH daemon";

    port = lib.mkOption {
      type = lib.types.port;
      default = 22;
      description = "TCP port on which OpenSSH listens";
    };

    passwordAuthentication = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to allow password login";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to open the SSH port in the firewall";
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [cfg.port];
      settings = {
        PermitRootLogin = lib.mkDefault "no";
        PasswordAuthentication = lib.mkDefault cfg.passwordAuthentication;
      };
      openFirewall = cfg.openFirewall;
    };
  };
}
