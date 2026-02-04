# textbringer-tree-sitter

Tree-sitter based syntax highlighting plugin for Textbringer.

## Features

- Accurate syntax parsing with Tree-sitter
- Properly highlights Terraform/HCL `for`, `in`, and function calls (which Rouge fails to recognize)
- Emacs-style feature-based level control
- Customizable node mappings

## Installation

```ruby
gem 'textbringer-tree-sitter'
```

### Installing Parsers

Parsers are not bundled with the gem. Use the CLI tool to install them:

```bash
# List available parsers
textbringer-tree-sitter list

# Install a specific parser (downloads prebuilt or builds from source)
textbringer-tree-sitter get ruby
textbringer-tree-sitter get hcl
textbringer-tree-sitter get markdown

# Install all prebuilt parsers at once
textbringer-tree-sitter get-all
```

### Parser Location

Parsers are stored in `~/.textbringer/parsers/{platform}/`.

```bash
# Show parser directory
textbringer-tree-sitter path
```

## Usage

Once a parser is installed and a node_map exists for the language, syntax highlighting is automatically enabled for the corresponding Mode.

For custom Modes, call `use_tree_sitter`:

```ruby
class MyMode < ProgrammingMode
  extend Textbringer::TreeSitterAdapter::ClassMethods
  use_tree_sitter :ruby
end
```

## Customization

### Highlight Level (Emacs-style)

```ruby
# ~/.textbringer.rb

# Level 1: comment, string only
# Level 2: + keyword, type, constant
# Level 3: + function_name, variable, number (default)
# Level 4: + operator, punctuation, builtin

CONFIG[:tree_sitter_highlight_level] = 4
```

### Individual Feature Selection

```ruby
CONFIG[:tree_sitter_enabled_features] = [:comment, :string, :keyword]
```

### Custom Node Mappings

```ruby
Textbringer::TreeSitter::NodeMaps.register(:ruby, {
  my_custom_node: :keyword
})
```

### Custom Parser Path

```ruby
CONFIG[:tree_sitter_parser_dir] = "/path/to/your/parsers"
```

## Supported Languages

### Prebuilt Parsers (via Faveod)

bash, c, c-sharp, cobol, embedded-template, groovy, haml, html, java, javascript, json, pascal, php, python, ruby, rust

### Build-required Parsers

| Language | Command |
|----------|---------|
| HCL (Terraform) | `textbringer-tree-sitter get hcl` |
| YAML | `textbringer-tree-sitter get yaml` |
| Go | `textbringer-tree-sitter get go` |
| TypeScript | `textbringer-tree-sitter get typescript` |
| TSX | `textbringer-tree-sitter get tsx` |
| SQL | `textbringer-tree-sitter get sql` |
| Markdown | `textbringer-tree-sitter get markdown` |

## License

WTFPL - See LICENSE.txt for details.

## Disclaimer

THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
