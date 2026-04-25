{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pi-coding-agent = { lib, buildNpmPackage, fetchurl }:
        buildNpmPackage rec {
          pname = "pi-coding-agent";
          version = "0.70.2";

          src = fetchurl {
            url = "https://registry.npmjs.org/@mariozechner/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
            sha256 = "1mbm0qv0xghs3p1zz57i9iavv37gzjvhgf29bqad5lhvcjl8kzvf";
          };

          postPatch = ''
            cp ${./package-lock.json} package-lock.json
          '';

          npmDepsHash = "sha256-bG1Hg8sH8kY0IEkL2CWdscrVLMVL6PDfDkTS5RviPDg=";

          dontNpmBuild = true;

          meta = {
            description = "Coding agent CLI with read, bash, edit, write tools and session management";
            homepage = "https://github.com/badlogic/pi-mono";
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
