{
  description = "Aaron's Nix configurations";

  inputs = {
    # 想切稳定版：改成 github:NixOS/nixpkgs/nixos-26.05 后 `nix flake update`
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation.url = "github:nix-community/preservation";
  };

  outputs = inputs @ {nixpkgs, ...}: let
    inherit (nixpkgs) lib;

    myvars = import ./vars;
    configurations = import ./hosts {inherit inputs myvars;};

    supportedSystems = ["aarch64-darwin" "x86_64-linux"];
    forEachSystem = lib.genAttrs supportedSystems;
  in
    configurations
    // {
      formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.alejandra);
    };
}
