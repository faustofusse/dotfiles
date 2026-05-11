{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    xremap-flake.url = "github:xremap/nix-flake";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    dotfiles = { url = "path:.."; flake = false; };
    pi-coding-agent = {
      url = "path:pkgs/pi-coding-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opencode = {
      url = "path:pkgs/opencode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly = {
      url = "path:pkgs/neovim-nightly";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... } @ inputs :
    let
      pi-coding-agent = system: inputs.pi-coding-agent.packages.${system}.default;
      opencode = system: inputs.opencode.packages.${system}.default;
      neovim-nightly = system: inputs.neovim-nightly.packages.${system}.default;
    in
    {
    packages.x86_64-linux.pi-coding-agent = pi-coding-agent "x86_64-linux";
    packages.aarch64-darwin.pi-coding-agent = pi-coding-agent "aarch64-darwin";
    packages.x86_64-linux.opencode = opencode "x86_64-linux";
    packages.aarch64-darwin.opencode = opencode "aarch64-darwin";
    packages.x86_64-linux.neovim-nightly = neovim-nightly "x86_64-linux";
    packages.aarch64-darwin.neovim-nightly = neovim-nightly "aarch64-darwin";

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
