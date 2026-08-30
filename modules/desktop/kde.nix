{
  config,
  lib,
  ...
}: let
  cfg = config.desktop'.kde;
in {
  options.desktop'.kde = {
    enable = lib.mkEnableOption "KDE Plasma 6 desktop with SDDM";
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
  };
}
