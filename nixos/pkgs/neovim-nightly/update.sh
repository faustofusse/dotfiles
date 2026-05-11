#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Updating neovim-nightly flake lock..."
cd "$SCRIPT_DIR"
nix flake update

echo "==> Verifying build for current system..."
nix build --no-link "$SCRIPT_DIR#default"

VERSION=$(nix eval --raw "$SCRIPT_DIR#default.version" 2>/dev/null || echo "unknown")
echo "==> Done! Neovim nightly updated to $VERSION."

echo "==> Checking nix profile..."
PROFILE_JSON=$(nix profile list --json 2>/dev/null || true)

PROFILE_NAME=$(echo "$PROFILE_JSON" | jq -r '
    .elements | to_entries[]
    | select(.key | contains("neovim-nightly"))
    | .key
')

if [ -n "$PROFILE_NAME" ]; then
    echo "    Found in nix profile as '$PROFILE_NAME', upgrading..."
    nix profile upgrade "$PROFILE_NAME"
    echo "    Profile upgraded."
else
    echo "    Not installed via nix profile, skipping."
fi
