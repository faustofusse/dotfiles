{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pi-coding-agent = { lib, buildNpmPackage, fetchurl }:
        buildNpmPackage rec {
          pname = "pi-coding-agent";
          version = "0.75.4";

          src = fetchurl {
            url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
            sha256 = "15yn32wbkbhl5gi2nl43gv1lvn53sqz8bfp7fnv2qjw2l9sbaryp";
          };

          postPatch = ''
            rm -f npm-shrinkwrap.json
            cp ${./package-lock.json} package-lock.json
          '';

          npmDepsHash = "sha256-Bsv4/7wNRy9k8bKigY1r+pS5V/5Bb+3MztHVA+iSbew=";
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
