# textbringer-tree-sitter

Tree-sitter による Textbringer のシンタックスハイライトプラグイン。

## 特徴

- Tree-sitter による正確な構文解析
- Rouge で認識されない Terraform/HCL の `for`, `in`, 関数呼び出しを正しくハイライト
- Emacs 風の feature-based レベル制御
- カスタマイズ可能なノードマッピング

## インストール

```ruby
gem 'textbringer-tree-sitter'
```

gem install 時に以下の parser が自動でダウンロードされます:
- Ruby, Python, JavaScript, JSON, Bash

### 追加 Parser のインストール

```bash
# 利用可能な parser を確認
textbringer-tree-sitter list

# HCL (Terraform) parser をビルド＆インストール
textbringer-tree-sitter get hcl

# YAML parser をビルド＆インストール
textbringer-tree-sitter get yaml

# Go parser をビルド＆インストール
textbringer-tree-sitter get go

# プリビルド済み parser をすべてインストール
textbringer-tree-sitter get-all
```

### Parser の配置場所

Parser は `~/.textbringer/parsers/{platform}/` に配置されます。

```bash
# 配置先を確認
textbringer-tree-sitter path
```

## 使い方

Mode で `use_tree_sitter` を呼ぶだけ:

```ruby
class RubyMode < ProgrammingMode
  extend Textbringer::TreeSitterAdapter::ClassMethods
  use_tree_sitter :ruby
end
```

## カスタマイズ

### ハイライトレベル (Emacs 風)

```ruby
# ~/.textbringer.rb

# Level 1: comment, string のみ
# Level 2: + keyword, type, constant
# Level 3: + function_name, variable, number (デフォルト)
# Level 4: + operator, punctuation, builtin

CONFIG[:tree_sitter_highlight_level] = 4
```

### 個別 Feature 指定

```ruby
CONFIG[:tree_sitter_enabled_features] = [:comment, :string, :keyword]
```

### カスタムノードマッピング

```ruby
Textbringer::TreeSitter::NodeMaps.register(:ruby, {
  my_custom_node: :keyword
})
```

### カスタム Parser パス

```ruby
CONFIG[:tree_sitter_parser_dir] = "/path/to/your/parsers"
```

## サポート言語

### 自動インストール（プリビルド）

| 言語 | 状態 |
|------|------|
| Ruby | ✓ 自動 |
| Python | ✓ 自動 |
| JavaScript | ✓ 自動 |
| JSON | ✓ 自動 |
| Bash | ✓ 自動 |
| C | `get c` |
| Java | `get java` |
| Rust | `get rust` |
| HTML | `get html` |
| PHP | `get php` |

### 要ビルド（コマンドで取得）

| 言語 | コマンド |
|------|----------|
| HCL (Terraform) | `textbringer-tree-sitter get hcl` |
| YAML | `textbringer-tree-sitter get yaml` |
| Go | `textbringer-tree-sitter get go` |
| TypeScript | `textbringer-tree-sitter get typescript` |
| C# | `textbringer-tree-sitter get csharp` |
| Groovy | `textbringer-tree-sitter get groovy` |

## ライセンス

WTFPL
