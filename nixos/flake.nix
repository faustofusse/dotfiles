{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    xremap-flake.url = "github:xremap/nix-flake";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    dotfiles = { url = "path:.."; flake = false; };
  };

  outputs = { self, nixpkgs, ... } @ inputs :
    let
      pi-coding-agent = system: (builtins.getFlake (toString ./. + "/pkgs/pi-coding-agent")).packages.${system}.default;
    in
    {
    packages.x86_64-linux.pi-coding-agent = pi-coding-agent "x86_64-linux";
    packages.aarch64-darwin.pi-coding-agent = pi-coding-agent "aarch64-darwin";

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
    nixosConfigurations."faulenovo" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs;
      modules = [ ./hosts/lenovo.nix ./configuration.nix ];
    };
    nixosConfigurations."thinkpad" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs;
      modules = [ ./hosts/thinkpad.nix ./configuration.nix ];
    };

    nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs;
      modules = [ ./hosts/iso.nix ./configuration.nix ];
    };
    packages."x86_64-linux".iso = self.nixosConfigurations.iso.config.system.build.isoImage;
    defaultPackage."x86_64-linux" = self.packages."x86_64-linux".iso;
  };
}
