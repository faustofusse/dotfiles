{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    xremap-flake.url = "github:xremap/nix-flake";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    dotfiles = { url = "path:.."; flake = false; };

    opencode.url = "path:./pkgs/opencode";
    tuify.url = "path:./pkgs/tuify";
    neovim-nightly.url = "path:./pkgs/neovim-nightly";
    pi-coding-agent.url = "github:earendil-works/pi/stable";
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
