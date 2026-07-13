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

### Opt-out of Automatic Downloads

To skip automatic parser downloads (useful in offline or restricted environments), set the environment variable:

```bash
export TEXTBRINGER_TREE_SITTER_NO_DOWNLOAD=1
gem install textbringer-tree-sitter
```

When this variable is set:
- `gem install` will skip automatic parser downloads
- CLI commands (`get`, `get-all`) will refuse to download with an error message
- You can still manually place parsers in `~/.textbringer/parsers/{platform}/`

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

### Disabling Tree-sitter for Specific Modes

You can disable Tree-sitter highlighting for specific modes:

```ruby
# Disable for RubyMode (falls back to default Textbringer highlighting)
RubyMode.tree_sitter_enabled = false

# Re-enable when needed
RubyMode.tree_sitter_enabled = true
```

## Custom Languages

You can add languages not included in the gem by creating a configuration file.

### 1. Initialize config file

```bash
textbringer-tree-sitter init
```

This creates `~/.textbringer/tree_sitter/languages.yml`.

### 2. Edit the configuration file

```yaml
# Simple format (minimal config)
elixir:
  repo: elixir-lang/tree-sitter-elixir

# Detailed format (full control)
zig:
  repo: maxxnino/tree-sitter-zig
  branch: master
  commit: abc123  # Optional: pin to specific commit
  subdir: ""      # Optional: subdirectory within repo
  build_cmd: "cc -shared -fPIC -O2 -I{src}/src {src}/src/parser.c -o {output}"

# Use a fork instead of curated version
ruby:
  repo: my-username/tree-sitter-ruby
  branch: experimental

# Use Faveod prebuilt parser
groovy:
  source: faveod
```

### 3. Install the language

```bash
textbringer-tree-sitter get elixir
```

The custom language will override any curated language with the same name.

### 4. List all languages

```bash
textbringer-tree-sitter list
```

This shows both curated (built-in) and user-defined languages.

### Worked Example: Adding Lua

Lua isn't in the curated list, so here's the full flow end to end, using
[tree-sitter-grammars/tree-sitter-lua](https://github.com/tree-sitter-grammars/tree-sitter-lua).

1. Create the config file if you haven't already:

   ```bash
   textbringer-tree-sitter init
   ```

2. Append a Lua entry to `~/.textbringer/tree_sitter/languages.yml`:

   ```yaml
   lua:
     repo: tree-sitter-grammars/tree-sitter-lua
     branch: main
   ```

   No `build_cmd` is needed here — Lua's grammar has a plain `scanner.c`
   (no C++ scanner), so the CLI's auto-detection in `guess_build_cmd`
   picks the right compiler and flags on its own.

3. Build the parser and generate a node map in one step:

   ```bash
   textbringer-tree-sitter get lua
   ```

   This clones the repo, builds `libtree-sitter-lua.{so,dylib}` into
   `~/.textbringer/parsers/{platform}/`, then generates
   `~/.textbringer/tree_sitter/node_maps/lua.rb` since Lua has no
   node_map bundled with the gem.

4. Review the generated node map. The heuristic mapper does a
   reasonable job on keywords, strings, and comments, but always
   check the "Unmapped nodes" comment block at the bottom — this is
   where node types the heuristics couldn't guess end up, and where
   grammar-specific structural nodes (e.g. `assignment_statement`,
   `function_declaration`) usually need a manual decision. Move any of
   those you care about into a face, or leave them commented out to
   mean "no highlighting for this node type":

   ```ruby
   # lib/textbringer/tree_sitter/node_maps/lua.rb (excerpt)
   LUA_FEATURES = {
     keyword: %i[end return goto do while until if else for in function global nil false true or and not],
     variable: %i[identifier variable_list variable_declaration implicit_variable_declaration variable],
     number: %i[number for_numeric_clause],
     comment: %i[comment_content comment],
     string: %i[string_content string],
     punctuation: %i[bracket_index_expression parenthesized_expression],
     function_name: %i[function_call],
   }.freeze
   ```

5. Load the node map from `~/.textbringer.rb`:

   ```ruby
   require "~/.textbringer/tree_sitter/node_maps/lua.rb"
   ```

6. Wire up a Mode for `.lua` files (Textbringer doesn't ship a LuaMode,
   so define a minimal one with `file_name_pattern`, the same
   mechanism `RubyMode`/`CMode` use), also in `~/.textbringer.rb`:

   ```ruby
   class LuaMode < Textbringer::ProgrammingMode
     self.file_name_pattern = /\.lua\z/
     extend Textbringer::TreeSitterAdapter::ClassMethods
     use_tree_sitter :lua
   end
   ```

Opening a `.lua` file now highlights via the node map from step 4.

#### Troubleshooting

- **`Error: Build failed`** — the auto-detected build command
  (`guess_build_cmd`) assumes a C or C++ scanner following the
  standard tree-sitter layout (`src/parser.c` + optional
  `src/scanner.{c,cc}`). Grammars with a nonstandard build (Rust
  helpers, generated bindings) need an explicit `build_cmd` in
  `languages.yml` — see the Zig/detailed-format example above.
- **`LANGUAGE_VERSION` mismatch at load time** — `ruby_tree_sitter`
  2.x accepts grammars built with tree-sitter ABI 6 through 14 (see
  `TreeSitter::MIN_COMPATIBLE_LANGUAGE_VERSION`/`LANGUAGE_VERSION`, or
  run `textbringer-tree-sitter doctor` to check installed parsers).
  Check `src/parser.c`'s `#define LANGUAGE_VERSION` in the grammar
  repo before adding it; pin a `commit:` if the default branch has
  since moved to an incompatible version.
- **Alias/name mismatches** — if the grammar's canonical name doesn't
  match how you want to refer to it (e.g. `c-sharp` vs `csharp`), see
  `lib/textbringer/tree_sitter/language_aliases.rb` for how curated
  languages register aliases.

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

To regenerate a node_map manually:
```bash
textbringer-tree-sitter generate-map <language>
```

## License

WTFPL - See [LICENSE](LICENSE) for details.

## Disclaimer

See [DISCLAIMER](DISCLAIMER) for details.
