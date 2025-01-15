{
  description = "Pet machine configuration of spitfire@stargem.xyz";

  nixConfig = {
    # extra-trusted-public-keys = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    # extra-substituters = "https://nix-community.cachix.org";
    allowUnfree = true;
    allow-import-from-derivation = true;
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-mgr.url = "github:nix-community/home-manager";
    hardware.url = "github:NixOS/nixos-hardware";
    flake-parts.url = "github:hercules-ci/flake-parts";
    stylix.url = "github:danth/stylix";
    devenv.url = "github:cachix/devenv/latest";
    #home-mgr.inputs.nixpkgs.follows = "nixpkgs";
    # drv-parts.url = "github:DavHau/drv-parts";
    # polymc.url = "github:PolyMC/PolyMC";
  };

  outputs = inputs@{ self, ... }: 
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = ["x86_64-linux"];
      imports = [
        # inputs.drv-parts.modules.flake-parts.drv-parts
        inputs.flake-parts.flakeModules.easyOverlay
      ];
  
      perSystem = { config, pkgs, final, ... }: {
        overlayAttrs = {
          inherit (config.packages) devenv vivaldi throttled;
        };
        packages.devenv = config.inputs.devenv.packages.default;
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
          inputs.stylix.nixosModules.stylix
          ./host/config.nix
          ./user/config.nix
        ];
      };

      flake.homeConfigurations.spitfire = inputs.home-mgr.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs;
        modules = [
          inputs.stylix.homeManagerModules.stylix
          ./user/abode.nix
        ];
      };

    };
}
