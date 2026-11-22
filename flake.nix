{
  description = "NixOS for the Framework Laptop 12";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/94c3211b0ee8ba969a3f12eb4aff8ba0f72971dd";
    nixos-hardware.url = "github:NixOS/nixos-hardware/33475966110df258f52d05ec4d4cd6394637cbb9";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nixos-hardware, ... }:
    let
      framework = nixos-hardware.nixosModules.framework-12-13th-gen-intel;
    in {
      nixosConfigurations = {
        framework12 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            framework
            ./hardware-configuration.nix
            ./configuration.nix
            ({ lib, ... }: {
              boot.loader.systemd-boot.enable = lib.mkDefault true;
              boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

              # Login for the standalone configuration.
              users.users.ethan = {
                isNormalUser = true;
                extraGroups = [ "wheel" "networkmanager" ];
              };

              # Initial NixOS release for this machine. Keep this across upgrades.
              system.stateVersion = "26.05";
            })
          ];
        };

        framework12-existing = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ framework ./existing-configuration.nix ./configuration.nix ];
        };
      };
    };
}
