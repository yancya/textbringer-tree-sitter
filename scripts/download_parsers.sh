#!/bin/bash
set -euo pipefail

# Parser ダウンロードスクリプト（CI 用）
# Usage: ./scripts/download_parsers.sh [languages...]
#   languages: ダウンロードする言語（省略時は ruby, hcl, markdown）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# プラットフォーム判定
if [[ "$(uname)" == "Darwin" ]]; then
  if [[ "$(uname -m)" == "arm64" ]]; then
    PLATFORM="darwin-arm64"
    EXT=".dylib"
  else
    PLATFORM="darwin-x64"
    EXT=".dylib"
  fi
else
  if [[ "$(uname -m)" == "aarch64" ]]; then
    PLATFORM="linux-arm64"
    EXT=".so"
  else
    PLATFORM="linux-x64"
    EXT=".so"
  fi
fi

PARSER_DIR="$PROJECT_DIR/parsers/$PLATFORM"
mkdir -p "$PARSER_DIR"

# Faveod プラットフォーム名変換
faveod_platform() {
  case "$PLATFORM" in
    darwin-arm64) echo "macos-arm64" ;;
    darwin-x64)   echo "macos-x64" ;;
    *)            echo "$PLATFORM" ;;
  esac
}

FAVEOD_PLATFORM=$(faveod_platform)

echo "Downloading parsers for $PLATFORM (Faveod: $FAVEOD_PLATFORM)..."

# デフォルトの言語リスト
if [[ $# -eq 0 ]]; then
  LANGUAGES=("ruby" "markdown")
else
  LANGUAGES=("$@")
fi

# Faveod/tree-sitter-parsers のリリースバージョン
RELEASE_VERSION="v4.11"
TARBALL_NAME="tree-sitter-parsers-${RELEASE_VERSION#v}-${FAVEOD_PLATFORM}.tar.gz"
TARBALL_URL="https://github.com/Faveod/tree-sitter-parsers/releases/download/${RELEASE_VERSION}/${TARBALL_NAME}"

# tarball を1回だけDL & 展開してキャッシュ
TARBALL_CACHE_DIR=""

ensure_tarball_extracted() {
  if [[ -n "$TARBALL_CACHE_DIR" ]]; then
    return 0
  fi

  TARBALL_CACHE_DIR=$(mktemp -d)
  local tarball="$TARBALL_CACHE_DIR/parsers.tar.gz"
  local extract_dir="$TARBALL_CACHE_DIR/extracted"

  echo "Downloading Faveod tarball..."
  echo "  URL: $TARBALL_URL"

  if ! curl -fsSL -o "$tarball" "$TARBALL_URL"; then
    echo "✗ Failed to download Faveod tarball"
    TARBALL_CACHE_DIR=""
    return 1
  fi

  if [[ ! -s "$tarball" ]]; then
    echo "✗ Downloaded tarball is empty"
    TARBALL_CACHE_DIR=""
    return 1
  fi

  mkdir -p "$extract_dir"
  tar -xzf "$tarball" -C "$extract_dir"
  echo "✓ Tarball extracted"
  return 0
}

cleanup_tarball_cache() {
  if [[ -n "$TARBALL_CACHE_DIR" ]]; then
    rm -rf "$TARBALL_CACHE_DIR"
  fi
}
trap cleanup_tarball_cache EXIT

download_parser() {
  local lang=$1
  local filename="libtree-sitter-${lang}${EXT}"
  local dest="$PARSER_DIR/$filename"

  echo "Installing $lang parser..."

  if ! ensure_tarball_extracted; then
    echo "✗ Warning: Could not download tarball for $lang parser"
    return 1
  fi

  local extract_dir="$TARBALL_CACHE_DIR/extracted"
  local src
  src=$(find "$extract_dir" -name "$filename" -print -quit)

  if [[ -n "$src" ]]; then
    cp "$src" "$dest"
    chmod 755 "$dest"
    echo "✓ $lang parser installed to $dest"
    return 0
  else
    echo "✗ $lang parser not found in tarball"
    return 1
  fi
}

build_hcl_parser() {
  echo "Building HCL parser from source..."
  TMP_DIR=$(mktemp -d)
  trap "rm -rf $TMP_DIR" RETURN

  cd "$TMP_DIR"
  if git clone --depth 1 https://github.com/mitchellh/tree-sitter-hcl.git 2>/dev/null; then
    cd tree-sitter-hcl
    if c++ -shared -fPIC -O2 -std=c++14 -Isrc src/parser.c src/scanner.cc -o "libtree-sitter-hcl${EXT}" 2>/dev/null; then
      cp "libtree-sitter-hcl${EXT}" "$PARSER_DIR/"
      echo "✓ HCL parser built and installed"
      return 0
    fi
  fi
  echo "✗ Failed to build HCL parser"
  return 1
}

# 各言語のパーサーをダウンロード
SUCCESS_COUNT=0
FAIL_COUNT=0

for lang in "${LANGUAGES[@]}"; do
  # HCL は Faveod にないのでビルド
  if [[ "$lang" == "hcl" ]]; then
    if build_hcl_parser; then
      ((SUCCESS_COUNT++)) || true
    else
      ((FAIL_COUNT++)) || true
    fi
  else
    if download_parser "$lang"; then
      ((SUCCESS_COUNT++)) || true
    else
      ((FAIL_COUNT++)) || true
    fi
  fi
done

echo ""
echo "Download complete: $SUCCESS_COUNT succeeded, $FAIL_COUNT failed"
echo "Parsers in $PARSER_DIR:"
ls -lh "$PARSER_DIR" | grep -v "^total" | grep -v ".gitkeep" || echo "(no parsers)"

if [[ $FAIL_COUNT -gt 0 ]]; then
  echo ""
  echo "Note: Some parsers failed to download. You may need to build them from source."
  echo "Run: ./scripts/build_parsers.sh"
  exit 1
fi

exit 0
