{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pi-coding-agent = { lib, buildNpmPackage, fetchurl }:
        buildNpmPackage rec {
          pname = "pi-coding-agent";
          version = "0.75.3";

          src = fetchurl {
            url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
            sha256 = "130nfhdkhxggwyi1n0i2jkpjsqibg2parv2i4mp151815yiw14k9";
          };

          postPatch = ''
            cp ${./package-lock.json} package-lock.json
          '';

          npmDepsHash = "sha256-bisEtdR6D+Gu9/XnFFDdO567lp90Pr3ywqvEQcUobOw=";

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
