# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

Textbringer（Ruby製ターミナルエディタ）に Tree-sitter ベースのシンタックスハイライトを提供するプラグイン gem。textbringer-rouge の代替として、より正確な構文解析を実現する（特に Terraform/HCL で Rouge の lexer に問題があるため）。

## 開発コマンド

```bash
bundle install
bundle exec rake test
bundle exec ruby -Ilib:test test/test_*.rb  # 単一テスト
bundle exec rake build
bundle exec rubocop
```

## アーキテクチャ

### 構造

```
lib/
├── textbringer/
│   ├── tree_sitter_adapter.rb    # Window モンキーパッチ + アダプター
│   ├── tree_sitter_config.rb     # Parser ロード、フェイス定義
│   └── tree_sitter/
│       ├── version.rb
│       └── node_maps/            # 言語ごとのノードマッピング
│           ├── ruby.rb
│           └── hcl.rb
└── textbringer_plugin.rb         # エントリポイント
parsers/                          # プリビルド parser (.dylib/.so)
├── darwin-arm64/
└── linux-x64/
```

### 主要コンポーネント

- **TreeSitterAdapter**: Window クラスをモンキーパッチして `custom_highlight` を実装
- **TreeSitterConfig**: プラットフォーム判定と parser ロード
- **NodeMaps**: 言語固有のノードタイプ → Face マッピング

### 依存関係

- `ruby_tree_sitter` (~> 2.0) - Faveod/ruby-tree-sitter
- `textbringer` (>= 1.0)

## Tree-sitter Parser

### LANGUAGE_VERSION 互換性

ruby_tree_sitter 2.0.0 は LANGUAGE_VERSION 6-14 をサポート。parser ビルド時は互換性を確認：

```bash
grep LANGUAGE_VERSION src/parser.c | head -1
```

### HCL Parser のビルド

mitchellh/tree-sitter-hcl を使用（LANGUAGE_VERSION 13）：

```bash
git clone https://github.com/mitchellh/tree-sitter-hcl.git
cd tree-sitter-hcl
c++ -shared -fPIC -O2 -std=c++14 -Isrc src/parser.c src/scanner.cc -o libtree-sitter-hcl.dylib
```

### プリビルド parser の取得

Faveod/tree-sitter-parsers から取得可能：bash, c, javascript, json, python, ruby, rust 等

## 参考実装

- [textbringer-rouge](https://github.com/yancya/textbringer-rouge) - Window モンキーパッチの実装パターン
