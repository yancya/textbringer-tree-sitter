# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

Textbringer（Ruby製ターミナルエディタ）に Tree-sitter ベースのシンタックスハイライトを提供するプラグイン gem。textbringer-rouge の代替として、より正確な構文解析を実現する（特に Terraform/HCL で Rouge の lexer に問題があるため）。

## Textbringer とは

* Ruby 製の Emacs 風テキストエディタ
* コマンド名は `txtb`

## 開発コマンド

```bash
bundle install
bundle exec rake test
bundle exec ruby -Ilib:test test/test_*.rb  # 単一テスト
bundle exec rake build
bundle exec rubocop

# デバッグモード（/tmp/tree_sitter_debug.log に出力）
TEXTBRINGER_TREE_SITTER_DEBUG=1 textbringer
```

## CLI ツール

gem に同梱の `textbringer-tree-sitter` コマンドで parser 管理:

```bash
textbringer-tree-sitter list                # 利用可能な parser 一覧
textbringer-tree-sitter get <lang>          # parser ダウンロード/ビルド + node_map 自動生成
textbringer-tree-sitter get <lang> --no-map # node_map 生成をスキップ
textbringer-tree-sitter get-all             # Faveod prebuilt を一括インストール
textbringer-tree-sitter generate-map <lang> # 既存 parser から node_map 再生成
textbringer-tree-sitter path                # parser ディレクトリ表示
```

### Parser の配置場所

- `~/.textbringer/parsers/{platform}/` にインストールされる
- プラットフォーム例: `darwin-arm64`, `linux-x64`
- カスタムパスは `CONFIG[:tree_sitter_parser_dir]` で指定可能

### Parser の種類

- **Faveod prebuilt**: bash, c, c-sharp, cobol, embedded-template, groovy, haml, html, java, javascript, json, pascal, php, python, ruby, rust
- **ビルド必須**: hcl, yaml, go, typescript, tsx, sql, markdown (各リポジトリから clone & build)

## アーキテクチャ

### 構造

```
lib/
├── textbringer/
│   ├── tree_sitter_adapter.rb    # Window モンキーパッチ + ハイライト実装
│   ├── tree_sitter_config.rb     # Parser パス解決、Face 定義
│   └── tree_sitter/
│       ├── version.rb
│       ├── node_maps.rb          # NodeMap レジストリ
│       └── node_maps/            # デフォルト NodeMap 定義
│           ├── ruby.rb, hcl.rb, bash.rb, ...
└── textbringer_plugin.rb         # エントリポイント
exe/
└── textbringer-tree-sitter       # CLI tool（parser 管理）
```

### 主要コンポーネント

- **TreeSitterAdapter**:
  - Window#highlight をモンキーパッチして `custom_highlight` に差し替え
  - Mode クラスに `use_tree_sitter(:lang)` を提供（prepend で注入）
  - Emacs 風 4 段階ハイライトレベル制御（HIGHLIGHT_LEVELS）

- **TreeSitterConfig**:
  - プラットフォーム検出（darwin-arm64, linux-x64 等）
  - Parser パス解決（CONFIG → ~/.textbringer/parsers → gem内 の優先順）
  - デフォルト Face 定義（comment, string, keyword, ...）

- **NodeMaps**:
  - 言語ごとの `node_type → face` マッピング辞書
  - `register(:lang, mapping)` でレジストリに登録
  - ユーザーカスタム NodeMap は `~/.textbringer/tree_sitter/node_maps/` に配置

### 依存関係

- `ruby_tree_sitter` (~> 2.0) - LANGUAGE_VERSION 6-14 対応
- `textbringer` (>= 1.0)

### カスタマイズ設定（~/.textbringer.rb）

```ruby
# ハイライトレベル (1-4, default: 3)
CONFIG[:tree_sitter_highlight_level] = 4

# 個別 feature 選択（レベルより優先）
CONFIG[:tree_sitter_enabled_features] = [:comment, :string, :keyword]

# カスタム parser ディレクトリ
CONFIG[:tree_sitter_parser_dir] = "/path/to/parsers"

# カスタム NodeMap 読み込み
require "~/.textbringer/tree_sitter/node_maps/mylang.rb"
```

## NodeMap の追加方法

新しい言語をサポートする手順:

1. **Parser インストール**
   ```bash
   textbringer-tree-sitter get <lang>  # 自動で node_map も生成される
   ```

2. **生成された NodeMap を確認・編集**
   - `~/.textbringer/tree_sitter/node_maps/<lang>.rb` に生成される
   - ヒューリスティックで推測されたマッピングをレビュー
   - コメント化された unmapped nodes を必要に応じて追加

3. **~/.textbringer.rb で読み込み**
   ```ruby
   require "~/.textbringer/tree_sitter/node_maps/<lang>.rb"
   ```

4. **gem にコントリビュート**（オプション）
   - `lib/textbringer/tree_sitter/node_maps/<lang>.rb` に配置
   - デフォルト NodeMap として同梱

## Tree-sitter Parser の互換性

### LANGUAGE_VERSION

ruby_tree_sitter 2.0.0 は **LANGUAGE_VERSION 6-14** をサポート。

ビルド前に互換性確認:
```bash
grep LANGUAGE_VERSION src/parser.c | head -1
```

### 手動ビルド例（HCL）

CLI tool 使わずビルドする場合:

```bash
git clone https://github.com/mitchellh/tree-sitter-hcl.git
cd tree-sitter-hcl
c++ -shared -fPIC -O2 -std=c++14 -Isrc src/parser.c src/scanner.cc -o libtree-sitter-hcl.dylib
cp libtree-sitter-hcl.dylib ~/.textbringer/parsers/darwin-arm64/
```

## リリース手順

1. `lib/textbringer/tree_sitter/version.rb` のバージョンを更新
2. PR を作成してマージ
3. main でタグを打つ（`git tag vX.Y.Z && git push origin vX.Y.Z`）
4. **gem push は GitHub Actions が自動で行う**（手動で `gem push` する必要はない）
5. GitHub Release のリリースノートを整備する（CI が自動作成するが、内容は手動で書き換える）

## 参考実装

- [textbringer-rouge](https://github.com/yancya/textbringer-rouge) - Window モンキーパッチの実装パターン
- [Faveod/tree-sitter-parsers](https://github.com/Faveod/tree-sitter-parsers) - prebuilt parsers の配布元
