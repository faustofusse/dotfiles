#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="anomalyco/opencode"

# Check for required tools
for cmd in curl jq nix-prefetch-url; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "ERROR: $cmd is required but not installed." >&2
        exit 1
    fi
done

echo "==> Fetching latest release from GitHub..."
LATEST_JSON=$(curl -sL "https://api.github.com/repos/$REPO/releases/latest")
LATEST_VERSION=$(echo "$LATEST_JSON" | jq -r '.tag_name' | sed 's/^v//')

if [[ -z "$LATEST_VERSION" || "$LATEST_VERSION" == "null" ]]; then
    echo "ERROR: Could not determine latest version." >&2
    exit 1
fi

echo "    Latest: $LATEST_VERSION"

CURRENT_VERSION=$(sed -n 's/.*version = "\([^"]*\)".*/\1/p' "$SCRIPT_DIR/flake.nix" || true)
echo "    Current: ${CURRENT_VERSION:-unknown}"

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
    echo "Already up to date."
    exit 0
fi

PLATFORMS=(
    "aarch64-darwin:darwin-arm64:.zip"
    "x86_64-darwin:darwin-x64:.zip"
    "x86_64-linux:linux-x64:.tar.gz"
    "aarch64-linux:linux-arm64:.tar.gz"
)

declare -A HASHES
declare -A NAMES

echo "==> Prefetching hashes for all platforms..."
for pair in "${PLATFORMS[@]}"; do
    nix_system="${pair%%:*}"
    rest="${pair#*:}"
    asset_name="${rest%:*}"
    ext="${rest##*:}"

    url="https://github.com/$REPO/releases/download/v${LATEST_VERSION}/opencode-${asset_name}${ext}"

    echo "    Fetching $asset_name..."
    hash=$(nix-prefetch-url --type sha256 "$url")
    sri_hash=$(nix hash convert --hash-algo sha256 --to sri "$hash")
    HASHES[$nix_system]="$sri_hash"
    NAMES[$nix_system]="$asset_name"
    echo "      $sri_hash"
done

echo "==> Writing flake.nix..."
cat > "$SCRIPT_DIR/flake.nix" <<EOF
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
              name = "${NAMES[aarch64-darwin]}";
              hash = "${HASHES[aarch64-darwin]}";
            };
            x86_64-darwin = {
              name = "${NAMES[x86_64-darwin]}";
              hash = "${HASHES[x86_64-darwin]}";
            };
            x86_64-linux = {
              name = "${NAMES[x86_64-linux]}";
              hash = "${HASHES[x86_64-linux]}";
            };
            aarch64-linux = {
              name = "${NAMES[aarch64-linux]}";
              hash = "${HASHES[aarch64-linux]}";
            };
          }.\${stdenv.hostPlatform.system} or (throw "Unsupported system: \${stdenv.hostPlatform.system}");

          version = "${LATEST_VERSION}";

          src = fetchurl {
            url = if isDarwin
              then "https://github.com/anomalyco/opencode/releases/download/v\${version}/opencode-\${platform.name}.zip"
              else "https://github.com/anomalyco/opencode/releases/download/v\${version}/opencode-\${platform.name}.tar.gz";
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
            \${if isDarwin then ''
              install -Dm755 \$src \$out/bin/opencode
            '' else ''
              install -Dm755 opencode \$out/bin/opencode
            ''}
            wrapProgram \$out/bin/opencode \\
              --prefix PATH : \${lib.makeBinPath (
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
EOF

echo "==> Verifying build for current system..."
nix build --no-link "$SCRIPT_DIR#default"

echo "==> Done! Updated opencode to $LATEST_VERSION"

echo "==> Checking nix profile..."
PROFILE_JSON=$(nix profile list --json 2>/dev/null || true)

PROFILE_NAME=$(echo "$PROFILE_JSON" | jq -r '
    .elements | to_entries[]
    | select(.key | contains("opencode"))
    | .key
')

if [ -n "$PROFILE_NAME" ]; then
    echo "    Found in nix profile as '$PROFILE_NAME', upgrading..."
    nix profile upgrade "$PROFILE_NAME"
    echo "    Profile upgraded."
else
    echo "    Not installed via nix profile, skipping."
fi
