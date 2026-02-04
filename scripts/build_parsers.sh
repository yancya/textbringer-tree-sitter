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

# Ruby parser はプリビルド版をダウンロード
echo "Downloading Ruby parser..."
cd "$TMP_DIR"

RUBY_PARSER_URL="https://github.com/Faveod/tree-sitter-parsers/releases/download/v0.1.0/libtree-sitter-ruby-$PLATFORM$EXT"
if curl -fsSL -o "libtree-sitter-ruby$EXT" "$RUBY_PARSER_URL" 2>/dev/null; then
  cp "libtree-sitter-ruby$EXT" "$PARSER_DIR/"
  echo "Ruby parser installed to $PARSER_DIR/libtree-sitter-ruby$EXT"
else
  echo "Warning: Could not download Ruby parser. Building from source..."
  git clone --depth 1 https://github.com/tree-sitter/tree-sitter-ruby.git
  cd tree-sitter-ruby
  if [[ "$EXT" == ".dylib" ]]; then
    cc -shared -fPIC -O2 -Isrc src/parser.c src/scanner.c -o "libtree-sitter-ruby$EXT"
  else
    cc -shared -fPIC -O2 -Isrc src/parser.c src/scanner.c -o "libtree-sitter-ruby$EXT"
  fi
  cp "libtree-sitter-ruby$EXT" "$PARSER_DIR/"
  echo "Ruby parser installed to $PARSER_DIR/libtree-sitter-ruby$EXT"
fi

echo ""
echo "Done! Parsers installed to $PARSER_DIR"
ls -la "$PARSER_DIR"
