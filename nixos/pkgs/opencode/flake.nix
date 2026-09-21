{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      opencode = { lib, stdenv, fetchurl, makeBinaryWrapper, autoPatchelfHook, ripgrep, sysctl, zlib, unzip }:
        let
          isLinux = stdenv.hostPlatform.isLinux;
          isDarwin = stdenv.hostPlatform.isDarwin;

          platform = {
            aarch64-darwin = {
              name = "darwin-arm64";
              hash = "sha256-NzzzZnODbyzohHKVoLss0kR9A8dptE2EGFkWvUcbQnQ=";
            };
            x86_64-darwin = {
              name = "darwin-x64";
              hash = "sha256-a2F9p1tXc4NvzcckfX6ivTmuyUKli4mgQbr7PU0qjCM=";
            };
            x86_64-linux = {
              name = "linux-x64";
              hash = "sha256-q3AVzYET4BGkYfMKDCt32CmaFE/2iMti6T6IAoNdcog=";
            };
            aarch64-linux = {
              name = "linux-arm64";
              hash = "sha256-htOvr06HhPmtqxib4qMVwSsn7ECgS3De++cFlcPMfGU=";
            };
          }.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

          version = "1.18.23";

          src = fetchurl {
            url = if isDarwin
              then "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-${platform.name}.zip"
              else "https://github.com/anomalyco/opencode/releases/download/v${version}/opencode-${platform.name}.tar.gz";
            hash = platform.hash;
          };
        in
        stdenv.mkDerivation ({
          inherit src version;
          pname = "opencode";

          nativeBuildInputs = [ makeBinaryWrapper ]
            ++ lib.optionals isLinux [ autoPatchelfHook ]
            ++ lib.optionals isDarwin [ unzip ];

          buildInputs = lib.optionals isLinux [ stdenv.cc.cc.lib zlib ];

          dontStrip = true;
          sourceRoot = ".";

          installPhase = ''
            runHook preInstall
            install -Dm755 opencode $out/bin/opencode
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
        });
    in
    {
      packages.aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.callPackage opencode {};
      packages.x86_64-darwin.default = nixpkgs.legacyPackages.x86_64-darwin.callPackage opencode {};
      packages.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.callPackage opencode {};
      packages.aarch64-linux.default = nixpkgs.legacyPackages.aarch64-linux.callPackage opencode {};
    };
}
