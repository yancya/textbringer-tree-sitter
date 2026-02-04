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

Parser は別途インストールが必要です:

```bash
# Ruby parser
curl -L -o parsers/darwin-arm64/libtree-sitter-ruby.dylib \
  https://github.com/Faveod/tree-sitter-parsers/releases/download/v0.1.0/libtree-sitter-ruby-darwin-arm64.dylib

# HCL parser (mitchellh/tree-sitter-hcl からビルド)
git clone https://github.com/mitchellh/tree-sitter-hcl.git
cd tree-sitter-hcl
c++ -shared -fPIC -O2 -std=c++14 -Isrc src/parser.c src/scanner.cc -o libtree-sitter-hcl.dylib
cp libtree-sitter-hcl.dylib /path/to/gem/parsers/darwin-arm64/
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

## サポート言語

- Ruby
- HCL (Terraform)

## ライセンス

WTFPL
