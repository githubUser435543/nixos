{
  description = "NixOS for the Framework Laptop 12";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/94c3211b0ee8ba969a3f12eb4aff8ba0f72971dd";
    nixos-hardware.url = "github:NixOS/nixos-hardware/33475966110df258f52d05ec4d4cd6394637cbb9";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nixos-hardware, ... }: {
    nixosConfigurations.framework12 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixos-hardware.nixosModules.framework-12-13th-gen-intel
        ./existing-configuration.nix
        ./configuration.nix
        ({ lib, ... }: {
          # Apply the profile hostname over the hostname set by the installer.
          networking.hostName = lib.mkOverride 90 "BarakObama";

          users.users.ethan = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" ];
          };

          # Preserve the installed stateVersion when it is set.
          system.stateVersion = lib.mkDefault "26.05";
        })
      ];
    };
  };
}
