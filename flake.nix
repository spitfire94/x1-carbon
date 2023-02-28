{
  description = "Spitfire's pet machine configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hardware.url = "github:NixOS/nixos-hardware";
    home-mgr.url = "github:nix-community/home-manager";
    home-mgr.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    drv-parts.url = "github:DavHau/drv-parts";
    stylix.url = "github:danth/stylix";
    oily.url = "github:StargemSystems/oily";
  };

  outputs = inputs@{ self, ... }: 
  inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = ["x86_64-linux"];
    flake.nixosConfigurations.carbon = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      system = "x86_64-linux";
      modules = [
        inputs.hardware.nixosModules.lenovo-thinkpad-x1-7th-gen
        inputs.home-mgr.nixosModules.default
        ./host/config.nix
        ./user/config.nix
      ];
    };
  };
}