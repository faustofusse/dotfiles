#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="lounge/tuify"
BRANCH="develop"

# Check for required tools
for cmd in curl jq nix-prefetch-url; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "ERROR: $cmd is required but not installed." >&2
        exit 1
    fi
done

echo "==> Fetching latest commit from GitHub ($BRANCH branch)..."
LATEST_JSON=$(curl -sL "https://api.github.com/repos/$REPO/commits/$BRANCH")
LATEST_REV=$(echo "$LATEST_JSON" | jq -r '.sha')

if [[ -z "$LATEST_REV" || "$LATEST_REV" == "null" ]]; then
    echo "ERROR: Could not determine latest commit." >&2
    exit 1
fi

echo "    Latest: $LATEST_REV"

CURRENT_REV=$(sed -n 's/.*rev = "\([^"]*\)".*/\1/p' "$SCRIPT_DIR/flake.nix" || true)
echo "    Current: ${CURRENT_REV:-unknown}"

if [[ "$CURRENT_REV" == "$LATEST_REV" ]]; then
    echo "Already up to date."
    exit 0
fi

echo "==> Prefetching source hash..."
SOURCE_HASH=$(nix-prefetch-url --unpack "https://github.com/$REPO/archive/$LATEST_REV.tar.gz")
SOURCE_SRI=$(nix hash convert --hash-algo sha256 --to sri "$SOURCE_HASH")
echo "    $SOURCE_SRI"

echo "==> Updating flake.nix (rev + source hash)..."
sed -i "s|rev = \"[^\"]*\"|rev = \"$LATEST_REV\"|" "$SCRIPT_DIR/flake.nix"
sed -i "s|hash = \"[^\"]*\";|hash = \"$SOURCE_SRI\";|" "$SCRIPT_DIR/flake.nix"

echo "==> Checking if vendorHash changed..."
set +e
BUILD_OUTPUT=$(nix build --no-link "$SCRIPT_DIR#default" 2>&1)
BUILD_STATUS=$?
set -e

if [[ $BUILD_STATUS -ne 0 ]]; then
    VENDOR_HASH=$(echo "$BUILD_OUTPUT" | grep -oP 'got:\s+\Ksha256-[A-Za-z0-9+/=]+' || true)

    if [[ -n "$VENDOR_HASH" ]]; then
        echo "    New vendorHash: $VENDOR_HASH"
        sed -i "s|vendorHash = \"[^\"]*\"|vendorHash = \"$VENDOR_HASH\"|" "$SCRIPT_DIR/flake.nix"
    else
        echo "ERROR: Build failed but could not extract new vendorHash." >&2
        echo "$BUILD_OUTPUT" >&2
        exit 1
    fi
else
    echo "    vendorHash unchanged."
fi

echo "==> Verifying build..."
nix build --no-link "$SCRIPT_DIR#default"

echo "==> Done! Updated tuify to $LATEST_REV"

echo "==> Checking nix profile..."
PROFILE_JSON=$(nix profile list --json 2>/dev/null || true)

PROFILE_NAME=$(echo "$PROFILE_JSON" | jq -r '
    .elements | to_entries[]
    | select(.key | contains("tuify"))
    | .key
')

if [ -n "$PROFILE_NAME" ]; then
    echo "    Found in nix profile as '$PROFILE_NAME', upgrading..."
    nix profile upgrade "$PROFILE_NAME"
    echo "    Profile upgraded."
else
    echo "    Not installed via nix profile, skipping."
fi
