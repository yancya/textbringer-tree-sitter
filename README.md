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

### Default Parsers

The following parsers are **automatically installed** during `gem install`:

- **ruby**
- **python**
- **javascript**
- **json**
- **bash**

These are downloaded from [Faveod/tree-sitter-parsers](https://github.com/Faveod/tree-sitter-parsers) and placed in `~/.textbringer/parsers/{platform}/`.

### Installing Additional Parsers

Use the CLI tool to install additional parsers:

```bash
# List available parsers and their installation status
textbringer-tree-sitter list

# Install a specific parser (downloads prebuilt or builds from source)
# Also generates a node_map if one doesn't exist in the gem
textbringer-tree-sitter get hcl
textbringer-tree-sitter get markdown

# Install parser only, skip node_map generation
textbringer-tree-sitter get markdown --no-map

# Install all Faveod prebuilt parsers at once
textbringer-tree-sitter get-all
```

### Parser Location

Parsers are stored in `~/.textbringer/parsers/{platform}/`.

```bash
# Show parser directory
textbringer-tree-sitter path
```

## Usage

### Automatic Highlighting

Once a parser is installed and a node_map exists for the language, syntax highlighting is automatically enabled for the corresponding Mode (e.g., RubyMode, PythonMode, HCLMode).

The `get` command:
1. Downloads or builds the parser
2. Automatically generates a node_map if one doesn't exist in the gem
3. Places the node_map in `~/.textbringer/tree_sitter/node_maps/`

### Custom Modes

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

### Ready to Use (Prebuilt + Node Map Included)

These parsers are available from Faveod and include node_maps in the gem:

| Language | Auto-installed on `gem install` | Command |
|----------|--------------------------------|---------|
| bash | ✅ | `textbringer-tree-sitter get bash` |
| c | | `textbringer-tree-sitter get c` |
| c-sharp | | `textbringer-tree-sitter get c-sharp` |
| cobol | | `textbringer-tree-sitter get cobol` |
| embedded-template | | `textbringer-tree-sitter get embedded-template` |
| groovy | | `textbringer-tree-sitter get groovy` |
| haml | | `textbringer-tree-sitter get haml` |
| html | | `textbringer-tree-sitter get html` |
| java | | `textbringer-tree-sitter get java` |
| javascript | ✅ | `textbringer-tree-sitter get javascript` |
| json | ✅ | `textbringer-tree-sitter get json` |
| pascal | | `textbringer-tree-sitter get pascal` |
| php | | `textbringer-tree-sitter get php` |
| python | ✅ | `textbringer-tree-sitter get python` |
| ruby | ✅ | `textbringer-tree-sitter get ruby` |
| rust | | `textbringer-tree-sitter get rust` |

### Build-required (Node Map Included)

These parsers require building from source but include node_maps:

| Language | Command | Repository |
|----------|---------|------------|
| HCL (Terraform) | `textbringer-tree-sitter get hcl` | mitchellh/tree-sitter-hcl |
| YAML | `textbringer-tree-sitter get yaml` | tree-sitter-grammars/tree-sitter-yaml |
| SQL | `textbringer-tree-sitter get sql` | m-novikov/tree-sitter-sql |

### Build-required (Node Map Not Included)

These parsers require building from source and node_map generation:

| Language | Command | Note |
|----------|---------|------|
| Go | `textbringer-tree-sitter get go` | Generates node_map in `~/.textbringer/tree_sitter/node_maps/` |
| TypeScript | `textbringer-tree-sitter get typescript` | Generates node_map in `~/.textbringer/tree_sitter/node_maps/` |
| TSX | `textbringer-tree-sitter get tsx` | Generates node_map in `~/.textbringer/tree_sitter/node_maps/` |
| Markdown | `textbringer-tree-sitter get markdown` | Generates node_map in `~/.textbringer/tree_sitter/node_maps/` |
| Nim | `textbringer-tree-sitter get nim` | Generates node_map. **Requires ~7GB RAM to build** |

To regenerate a node_map manually:
```bash
textbringer-tree-sitter generate-map <language>
```

## License

WTFPL - See LICENSE.txt for details.

## Disclaimer

THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
