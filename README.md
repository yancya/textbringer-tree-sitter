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

### Parser のインストール

Parser（`.dylib`/`.so`）は別途インストールが必要です。以下の場所を順に検索します:

1. `CONFIG[:tree_sitter_parser_dir]` （カスタム指定）
2. `~/.textbringer/parsers/{platform}/` （ユーザー共通、**推奨**）
3. gem 内の `parsers/{platform}/`

`{platform}` は `darwin-arm64`, `darwin-x64`, `linux-x64`, `linux-arm64` のいずれか。

```bash
# ディレクトリ作成
mkdir -p ~/.textbringer/parsers/darwin-arm64  # macOS Apple Silicon
mkdir -p ~/.textbringer/parsers/linux-x64     # Linux x64

# Ruby parser (プリビルド)
curl -L -o ~/.textbringer/parsers/darwin-arm64/libtree-sitter-ruby.dylib \
  https://github.com/Faveod/tree-sitter-parsers/releases/download/v0.1.0/libtree-sitter-ruby-darwin-arm64.dylib

# HCL parser (要ビルド)
git clone https://github.com/mitchellh/tree-sitter-hcl.git
cd tree-sitter-hcl
c++ -shared -fPIC -O2 -std=c++14 -Isrc src/parser.c src/scanner.cc -o libtree-sitter-hcl.dylib
cp libtree-sitter-hcl.dylib ~/.textbringer/parsers/darwin-arm64/
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

| 言語 | Parser 取得元 |
|------|--------------|
| Bash | Faveod/tree-sitter-parsers |
| C | Faveod/tree-sitter-parsers |
| C# | Faveod/tree-sitter-parsers |
| COBOL | Faveod/tree-sitter-parsers |
| Groovy | Faveod/tree-sitter-parsers |
| HAML | Faveod/tree-sitter-parsers |
| HCL (Terraform) | mitchellh/tree-sitter-hcl (要ビルド) |
| HTML | Faveod/tree-sitter-parsers |
| Java | Faveod/tree-sitter-parsers |
| JavaScript | Faveod/tree-sitter-parsers |
| JSON | Faveod/tree-sitter-parsers |
| Pascal | Faveod/tree-sitter-parsers |
| PHP | Faveod/tree-sitter-parsers |
| Python | Faveod/tree-sitter-parsers |
| Ruby | Faveod/tree-sitter-parsers |
| Rust | Faveod/tree-sitter-parsers |
| YAML | tree-sitter-grammars/tree-sitter-yaml (要ビルド) |

## ライセンス

WTFPL
