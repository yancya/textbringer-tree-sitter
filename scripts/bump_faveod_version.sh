#!/usr/bin/env bash
# Rewrite the pinned Faveod/tree-sitter-parsers version across the 4 files
# that carry it. See the a25be1d commit for the manual precedent.
set -euo pipefail

NEW_VERSION="${1:-}"

if [[ ! "$NEW_VERSION" =~ ^v[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
  echo "Error: invalid version '$NEW_VERSION' (expected format: vX.Y or vX.Y.Z)" >&2
  exit 1
fi

FILES=(
  ".github/workflows/sync-upstream.yml"
  "ext/textbringer_tree_sitter/extconf.rb"
  "scripts/build_parsers.sh"
  "scripts/download_parsers.sh"
)

for f in "${FILES[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "Error: $f not found" >&2
    exit 1
  fi
done

sed -i.bak -E "s/CURRENT=\"v[0-9]+\.[0-9]+(\.[0-9]+)?\"/CURRENT=\"${NEW_VERSION}\"/" ".github/workflows/sync-upstream.yml"
sed -i.bak -E "s/FAVEOD_VERSION = \"v[0-9]+\.[0-9]+(\.[0-9]+)?\"/FAVEOD_VERSION = \"${NEW_VERSION}\"/" "ext/textbringer_tree_sitter/extconf.rb"
sed -i.bak -E "s/FAVEOD_VERSION=\"v[0-9]+\.[0-9]+(\.[0-9]+)?\"/FAVEOD_VERSION=\"${NEW_VERSION}\"/" "scripts/build_parsers.sh"
sed -i.bak -E "s/RELEASE_VERSION=\"v[0-9]+\.[0-9]+(\.[0-9]+)?\"/RELEASE_VERSION=\"${NEW_VERSION}\"/" "scripts/download_parsers.sh"

for f in "${FILES[@]}"; do
  rm -f "${f}.bak"
done

echo "Bumped Faveod/tree-sitter-parsers version to ${NEW_VERSION} in: ${FILES[*]}"
