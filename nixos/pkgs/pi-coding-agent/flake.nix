{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pi-coding-agent = { lib, buildNpmPackage, fetchurl }:
        buildNpmPackage rec {
          pname = "pi-coding-agent";
          version = "0.86.1";

          src = fetchurl {
            url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
            sha256 = "0shb9aca42q0pmm8w9pf0rg4y2azpg3x4y1awycd9q03zbk97zwd";
          };

          postPatch = ''
            rm -f npm-shrinkwrap.json
            cp ${./package-lock.json} package-lock.json
          '';

          npmDepsHash = "sha256-M3YT72WpFRSm4HFwK9Gbr2zlqXdvAwX4JrxLbnbXVj4=";
          npmDepsFetcherVersion = 2;

          dontNpmBuild = true;

          meta = {
            description = "Coding agent CLI with read, bash, edit, write tools and session management";
            homepage = "https://github.com/earendil-works/pi-mono";
            license = lib.licenses.mit;
            mainProgram = "pi";
          };
        };
    in
    {
      packages.aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.callPackage pi-coding-agent {};
      packages.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.callPackage pi-coding-agent {};
    };
}
