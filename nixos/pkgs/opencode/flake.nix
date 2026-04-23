{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      opencode = { lib, stdenv, fetchurl, unzip, makeBinaryWrapper, ripgrep, sysctl }:
        let
          isLinux = stdenv.hostPlatform.isLinux;
          isDarwin = stdenv.hostPlatform.isDarwin;

          platform = {
            aarch64-darwin = {
              name = "darwin-arm64";
              hash = "sha256-zeqDvk2eEvD7SyFosSLwGj0CQ1k8r07IEEHF5tcX+Po=";
            };
            x86_64-darwin = {
              name = "darwin-x64";
              hash = "sha256-jV/184ZOjCVXce6vHU3zXFQVSXLcu+k7S6qqazIj49c=";
            };
            x86_64-linux = {
              name = "linux-amd64";
              hash = "sha256-C7GBxiaISt0S5H1bjS+IwculvVCnQnl6QYAkLmfa4nw=";
            };
            aarch64-linux = {
              name = "linux-arm64";
              hash = "sha256-ZOI+5b5ZETRPQAnXGr0UH+ZQ5eskrPDT6/yEyJ1L6uA=";
            };
          }.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

          version = "1.14.22";

          src = fetchurl {
            url = if isDarwin
              then "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-${platform.name}.zip"
              else "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-desktop-${platform.name}.deb";
            hash = platform.hash;
          };
        in
        stdenv.mkDerivation (rec {
          inherit src version;
          pname = "opencode";

          nativeBuildInputs = [ makeBinaryWrapper ]
            ++ lib.optionals isDarwin [ unzip ];

          sourceRoot = ".";

          installPhase = ''
            runHook preInstall
            ${if isDarwin then ''
              install -Dm755 opencode $out/bin/opencode
            '' else ''
              install -Dm755 usr/bin/opencode-cli $out/bin/opencode
            ''}
            wrapProgram $out/bin/opencode \
              --prefix PATH : ${lib.makeBinPath (
                [ ripgrep ]
                ++ lib.optionals isDarwin [ sysctl ]
              )}
            runHook postInstall
          '';

          meta = {
            description = "AI coding agent built for the terminal";
            homepage = "https://github.com/anomalyco/opencode";
            license = lib.licenses.mit;
            mainProgram = "opencode";
            platforms = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
          };
        } // lib.optionalAttrs isLinux {
          unpackPhase = ''
            runHook preUnpack
            ar x "$src"
            tar xzf data.tar.gz
            runHook postUnpack
          '';
        });
    in
    {
      packages.aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.callPackage opencode {};
      packages.x86_64-darwin.default = nixpkgs.legacyPackages.x86_64-darwin.callPackage opencode {};
      packages.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.callPackage opencode {};
      packages.aarch64-linux.default = nixpkgs.legacyPackages.aarch64-linux.callPackage opencode {};
    };
}
