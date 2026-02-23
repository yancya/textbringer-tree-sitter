#!/bin/bash
set -euo pipefail

# Parser ビルドスクリプト
# Usage: ./scripts/build_parsers.sh

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
FAVEOD_VERSION="v5.0"

echo "Building parsers for $PLATFORM..."

# 一時ディレクトリ
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

cd "$TMP_DIR"

# HCL parser をビルド
echo "Building HCL parser..."
git clone --depth 1 https://github.com/mitchellh/tree-sitter-hcl.git
cd tree-sitter-hcl

if [[ "$EXT" == ".dylib" ]]; then
  c++ -shared -fPIC -O2 -std=c++14 -Isrc src/parser.c src/scanner.cc -o "libtree-sitter-hcl$EXT"
else
  c++ -shared -fPIC -O2 -std=c++14 -Isrc src/parser.c src/scanner.cc -o "libtree-sitter-hcl$EXT"
fi

cp "libtree-sitter-hcl$EXT" "$PARSER_DIR/"
echo "HCL parser installed to $PARSER_DIR/libtree-sitter-hcl$EXT"

# Ruby parser はプリビルド版をダウンロード（Faveod tarball 方式）
echo "Downloading Ruby parser..."
cd "$TMP_DIR"

TARBALL_NAME="tree-sitter-parsers-${FAVEOD_VERSION#v}-${FAVEOD_PLATFORM}.tar.gz"
TARBALL_URL="https://github.com/Faveod/tree-sitter-parsers/releases/download/${FAVEOD_VERSION}/${TARBALL_NAME}"
EXTRACT_DIR="$TMP_DIR/faveod-extracted"

echo "  URL: $TARBALL_URL"
if curl -fsSL -o "$TMP_DIR/$TARBALL_NAME" "$TARBALL_URL" 2>/dev/null; then
  mkdir -p "$EXTRACT_DIR"
  tar -xzf "$TMP_DIR/$TARBALL_NAME" -C "$EXTRACT_DIR"

  # tarball 内から Ruby parser を探してコピー
  RUBY_SRC=$(find "$EXTRACT_DIR" -name "libtree-sitter-ruby$EXT" -print -quit)
  if [[ -n "$RUBY_SRC" ]]; then
    cp "$RUBY_SRC" "$PARSER_DIR/libtree-sitter-ruby$EXT"
    chmod 755 "$PARSER_DIR/libtree-sitter-ruby$EXT"
    echo "Ruby parser installed to $PARSER_DIR/libtree-sitter-ruby$EXT"
  else
    echo "Warning: Ruby parser not found in tarball. Building from source..."
    git clone --depth 1 https://github.com/tree-sitter/tree-sitter-ruby.git
    cd tree-sitter-ruby
    cc -shared -fPIC -O2 -Isrc src/parser.c src/scanner.c -o "libtree-sitter-ruby$EXT"
    cp "libtree-sitter-ruby$EXT" "$PARSER_DIR/"
    echo "Ruby parser installed to $PARSER_DIR/libtree-sitter-ruby$EXT"
  fi
else
  echo "Warning: Could not download Faveod tarball. Building from source..."
  git clone --depth 1 https://github.com/tree-sitter/tree-sitter-ruby.git
  cd tree-sitter-ruby
  cc -shared -fPIC -O2 -Isrc src/parser.c src/scanner.c -o "libtree-sitter-ruby$EXT"
  cp "libtree-sitter-ruby$EXT" "$PARSER_DIR/"
  echo "Ruby parser installed to $PARSER_DIR/libtree-sitter-ruby$EXT"
fi

echo ""
echo "Done! Parsers installed to $PARSER_DIR"
ls -la "$PARSER_DIR"
