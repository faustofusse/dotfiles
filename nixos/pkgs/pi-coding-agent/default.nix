{ lib, buildNpmPackage, fetchurl }:

buildNpmPackage rec {
  pname = "pi-coding-agent";
  version = "0.69.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@mariozechner/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = "sha256-b+1Rli77V/dRqgVAN7+qqqN57P/MUXxM4Wx35ZADU0U=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-HPcX4Igc6XkrGcKdZLsvxtoCn/qasd4hC/a0YLsfaiI=";

  dontNpmBuild = true;

  meta = {
    description = "Coding agent CLI with read, bash, edit, write tools and session management";
    homepage = "https://github.com/badlogic/pi-mono";
    license = lib.licenses.mit;
    mainProgram = "pi";
  };
}
