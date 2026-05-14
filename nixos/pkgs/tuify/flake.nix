{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      tuify = { lib, buildGoModule, fetchFromGitHub, pkg-config, alsa-lib }:
        buildGoModule {
          pname = "tuify";
          version = "0.0.1";

          src = fetchFromGitHub {
            owner = "lounge";
            repo = "tuify";
            rev = "423cc05a72a04d0a3b083dfc4de1a796c0bd8c3f";
            hash = "sha256-BfUrZnJkdfnNd+l0WHNsJPpVGrIeCmc4Lb/3P/Jx5ww=";
          };

          vendorHash = "sha256-N+5T5N2jZLrtGeO4GofbgK7gxf3CQC9Ke3UBSdRXIwk=";

          nativeBuildInputs = [ pkg-config ];
          buildInputs = [ alsa-lib ];

          meta = {
            description = "Spotify client without all the noise";
            homepage = "https://github.com/lounge/tuify";
            license = lib.licenses.mit;
            mainProgram = "tuify";
          };
        };
    in
    {
      packages.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.callPackage tuify {};
      packages.aarch64-linux.default = nixpkgs.legacyPackages.aarch64-linux.callPackage tuify {};
      packages.x86_64-darwin.default = nixpkgs.legacyPackages.x86_64-darwin.callPackage tuify {};
      packages.aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.callPackage tuify {};
    };
}
