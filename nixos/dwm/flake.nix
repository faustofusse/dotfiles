{
  description = "custom dwm";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let 
        pkgs = import nixpkgs { inherit system; };
      in
      rec {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ xorg.libX11 xorg.libXft xorg.libXinerama gcc bear ];
        };
      }
    );
}
