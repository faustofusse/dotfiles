#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_NAME="@mariozechner/pi-coding-agent"

echo "==> Fetching latest version from npm..."
LATEST_VERSION=$(npm view "$PACKAGE_NAME" version)
echo "    Latest: $LATEST_VERSION"

# Extract current version from flake.nix (portable, no grep -P)
CURRENT_VERSION=$(sed -n 's/.*version = "\([^"]*\)".*/\1/p' "$SCRIPT_DIR/flake.nix" || true)
echo "    Current: ${CURRENT_VERSION:-unknown}"

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
    echo "Already up to date."
    exit 0
fi

echo "==> Fetching source hash..."
SOURCE_HASH=$(nix-prefetch-url --type sha256 "https://registry.npmjs.org/$PACKAGE_NAME/-/pi-coding-agent-$LATEST_VERSION.tgz")
echo "    Source hash: $SOURCE_HASH"

echo "==> Generating package-lock.json..."
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

curl -sL "https://registry.npmjs.org/$PACKAGE_NAME/-/pi-coding-agent-$LATEST_VERSION.tgz" | tar xz -C "$TMPDIR" --strip-components=1
cd "$TMPDIR"
npm install --package-lock-only 2>/dev/null || true
cp package-lock.json "$SCRIPT_DIR/package-lock.json"
echo "    Updated package-lock.json"

echo "==> Writing flake.nix with fake npmDepsHash..."
cat > "$SCRIPT_DIR/flake.nix" <<EOF
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pi-coding-agent = { lib, buildNpmPackage, fetchurl }:
        buildNpmPackage rec {
          pname = "pi-coding-agent";
          version = "${LATEST_VERSION}";

          src = fetchurl {
            url = "https://registry.npmjs.org/@mariozechner/pi-coding-agent/-/pi-coding-agent-\${version}.tgz";
            sha256 = "${SOURCE_HASH}";
          };

          postPatch = ''
            cp \${./package-lock.json} package-lock.json
          '';

          npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

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
EOF

echo "==> Building to get correct npmDepsHash..."
set +e
BUILD_OUTPUT=$(nix build --no-link "$SCRIPT_DIR#default" 2>&1)
BUILD_STATUS=$?
set -e

if [[ $BUILD_STATUS -eq 0 ]]; then
    echo "==> Build succeeded immediately (dependencies unchanged?)"
else
    echo "==> Extracting npmDepsHash from build output..."
    NPM_HASH=$(echo "$BUILD_OUTPUT" | perl -nle 'print $1 if /npmDepsHash:\s*(sha256-[A-Za-z0-9+\/=]+)/')

    if [[ -z "$NPM_HASH" ]]; then
        NPM_HASH=$(echo "$BUILD_OUTPUT" | perl -nle 'print $1 if /got:\s+(sha256-[A-Za-z0-9+\/=]+)/')
    fi

    if [[ -z "$NPM_HASH" ]]; then
        NPM_HASH=$(echo "$BUILD_OUTPUT" | perl -nle 'print $1 if /(sha256-[A-Za-z0-9+\/=]{40,})/' | head -n1)
    fi

    if [[ -z "$NPM_HASH" ]]; then
        echo "ERROR: Could not extract npmDepsHash from build output."
        echo ""
        echo "Build output:"
        echo "$BUILD_OUTPUT"
        exit 1
    fi

    echo "    npmDepsHash: $NPM_HASH"

    echo "==> Updating flake.nix with correct npmDepsHash..."
    sed -i.bak -E "s|(npmDepsHash = \")[^\"]+(\";)|\1$NPM_HASH\2|" "$SCRIPT_DIR/flake.nix"
    rm -f "$SCRIPT_DIR/flake.nix.bak"

    echo "==> Verifying final build..."
    nix build --no-link "$SCRIPT_DIR#default"
fi

echo "==> Done! Updated pi-coding-agent to $LATEST_VERSION"

echo "==> Checking nix profile..."

# Use JSON output for reliable parsing
PROFILE_JSON=$(nix profile list --json 2>/dev/null || true)

PROFILE_NAME=$(echo "$PROFILE_JSON" | jq -r '
    .elements | to_entries[]
    | select(.key | contains("pi-coding-agent"))
    | .key
')

if [ -n "$PROFILE_NAME" ]; then
    echo "    Found in nix profile as '$PROFILE_NAME', upgrading..."
    nix profile upgrade "$PROFILE_NAME"
    echo "    Profile upgraded."
else
    echo "    Not installed via nix profile, skipping."
fi
