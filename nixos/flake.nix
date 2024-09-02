{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    xremap-flake.url = "github:xremap/nix-flake";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, ... } @ inputs : {
    nixosConfigurations."fauhp" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs;
      modules = [ ./hosts/hp.nix ./configuration.nix ];
    };
    nixosConfigurations."faumbp" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs;
      modules = [ ./hosts/mbp.nix ./configuration.nix ];
    };
  };
}
