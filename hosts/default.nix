{
  inputs,
  myvars,
}: let
  inherit (inputs.nixpkgs) lib;

  mkHost = hostName: _: let
    specialArgs = {inherit inputs myvars hostName;};
  in
    lib.nixosSystem {
      inherit specialArgs;
      modules = [
        (import ../modules "nixos")
        (./. + "/${hostName}")
      ];
    };

  mkConfigurations =
    lib.mapAttrs mkHost
    (lib.filterAttrs (
      hostName: type:
        type == "directory"
        && builtins.pathExists (./. + "/${hostName}/default.nix")
    ) (builtins.readDir ./.));
in {
  nixosConfigurations = mkConfigurations;
}
