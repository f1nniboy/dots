#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="$(dirname "$0")/words"

# Read 128-bit UUID
UUID="${1:-$(cat /sys/class/dmi/id/product_uuid)}"

# Remove dashes -> 32 hex characters
RAW="$(echo "$UUID" | tr -d '-')"

# Take first 64 bits (16 chars)
SEED_HEX="${RAW:0:16}"

# Convert hex -> unsigned 64-bit decimal (never negative)
SEED_NUM="$(printf "%u" "0x$SEED_HEX")"

nix run nixpkgs#rust-petname -- \
    --seed "$SEED_NUM" \
    --dir "$DATA_DIR" \
    --words 1
