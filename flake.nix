{
  description = "Pet machine configuration of spitfire@stargem.xyz";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-mgr.url = "github:nix-community/home-manager";
    hardware.url = "github:NixOS/nixos-hardware";
    flake-parts.url = "github:hercules-ci/flake-parts";
    drv-parts.url = "github:DavHau/drv-parts";
    stylix.url = "github:danth/stylix";
    oily.url = "github:StargemSystems/oily";
    home-mgr.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, ... }: 
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = ["x86_64-linux"];
      imports = [
        inputs.drv-parts.modules.flake-parts.drv-parts
        inputs.flake-parts.flakeModules.easyOverlay
      ];
  
      perSystem = { config, pkgs, final, ... }: {
        overlayAttrs = {
          inherit (config.packages) vivaldi throttled;
        };
        packages.vivaldi = pkgs.vivaldi.overrideAttrs (old: {
          enableWidevine = true;
          proprietaryCodecs = true;
        });
        packages.throttled = pkgs.throttled.overrideAttrs (old: {
          postPatch = old.postPatch + ''
            substituteInPlace throttled.py --replace "'modprobe'" "'${pkgs.kmod}/bin/modprobe'"
          '';
        });
      };
  
      flake.nixosConfigurations.carbon = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
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