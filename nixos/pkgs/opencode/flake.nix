{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      opencode = { lib, stdenv, fetchurl, makeBinaryWrapper, autoPatchelfHook, ripgrep, sysctl, zlib }:
        let
          isLinux = stdenv.hostPlatform.isLinux;
          isDarwin = stdenv.hostPlatform.isDarwin;

          platform = {
            aarch64-darwin = {
              name = "darwin-arm64";
              hash = "sha256:1ypq2zbydia12344xbrwb51h4g8sy0ib2s119gxz04ly9nz87snd";
            };
            x86_64-darwin = {
              name = "darwin-x64";
              hash = "sha256:1mz34cr6pama9cxykfywf94iam2wyd6ivbzff5bjb32fhvrzapwd";
            };
            x86_64-linux = {
              name = "linux-x64";
              hash = "sha256:0rc1xs204jhaw8wzsy5icxs25hyw61qx7fmr46ikcxwwk0hcsik9";
            };
            aarch64-linux = {
              name = "linux-arm64";
              hash = "sha256:1hlp8lfyzfs5l879qnvh4h4mdrwvs2wz6fgd6c9d92rljps3rfxq";
            };
          }.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

          version = "1.14.22";

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
            ++ lib.optionals isLinux [ autoPatchelfHook ];

          buildInputs = lib.optionals isLinux [ stdenv.cc.cc.lib zlib ];

          dontStrip = true;
          dontUnpack = isDarwin;
          sourceRoot = ".";

          installPhase = ''
            runHook preInstall
            ${if isDarwin then ''
              install -Dm755 $src $out/bin/opencode
            '' else ''
              install -Dm755 opencode $out/bin/opencode
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
        });
    in
    {
      packages.aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.callPackage opencode {};
      packages.x86_64-darwin.default = nixpkgs.legacyPackages.x86_64-darwin.callPackage opencode {};
      packages.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.callPackage opencode {};
      packages.aarch64-linux.default = nixpkgs.legacyPackages.aarch64-linux.callPackage opencode {};
    };
}
