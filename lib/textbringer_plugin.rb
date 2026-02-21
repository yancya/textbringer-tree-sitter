# frozen_string_literal: true

# Textbringer plugin entry point
# Loaded when Textbringer auto-loads plugins

# Require tree_sitter gem first to prevent namespace collision
# (Define ::TreeSitter before Textbringer::TreeSitter)
begin
  require "tree_sitter"
rescue LoadError
  # Ignore if tree_sitter gem is not available (works without parser)
end

require "textbringer/tree_sitter/version"
require "textbringer/tree_sitter_config"
require "textbringer/tree_sitter/node_maps"
require "textbringer/tree_sitter_adapter"

# Define default Faces
Textbringer::TreeSitterConfig.define_default_faces

# Load user-defined node_maps
# ~/.textbringer/tree_sitter/node_maps/*.rb
user_node_maps_dir = File.expand_path("~/.textbringer/tree_sitter/node_maps")
if Dir.exist?(user_node_maps_dir)
  Dir.glob(File.join(user_node_maps_dir, "*.rb")).sort.each do |file|
    begin
      require file
    rescue => e
      warn "textbringer-tree-sitter: Failed to load #{file}: #{e.message}"
    end
  end
end

# Existing Mode -> language mapping
MODE_LANGUAGE_MAP = {
  "RubyMode" => :ruby,
  "CMode" => :c,
  "JavaScriptMode" => :javascript,
  "PythonMode" => :python,
  "RustMode" => :rust,
  "BashMode" => :bash,
  "ShMode" => :bash,
  "HCLMode" => :hcl,
  "TerraformMode" => :hcl,
  "JSONMode" => :json,
  "YAMLMode" => :yaml,
  "HTMLMode" => :html,
  "JavaMode" => :java,
  "PHPMode" => :php,
  "MarkdownMode" => :markdown,
  "GoMode" => :go,
  "TypeScriptMode" => :typescript,
  "TSXMode" => :tsx,
  "SQLMode" => :sql,
  "ElixirMode" => :elixir,
  "KotlinMode" => :kotlin,
  "ZigMode" => :zig,
  "CrystalMode" => :crystal,
  "SwiftMode" => :swift,
  "CobolMode" => :cobol,
  "CSharpMode" => :csharp,
  "GroovyMode" => :groovy,
  "HamlMode" => :haml,
  "PascalMode" => :pascal,
}.freeze

# Language -> file pattern (for automatic Mode generation)
LANGUAGE_FILE_PATTERNS = {
  markdown: /\.(md|markdown|mkd|mkdn)$/i,
  hcl: /\.(tf|tfvars|hcl)$/i,
  go: /\.go$/i,
  typescript: /\.ts$/i,
  tsx: /\.tsx$/i,
  sql: /\.sql$/i,
  yaml: /\.(ya?ml)$/i,
  json: /\.json$/i,
  python: /\.py$/i,
  rust: /\.rs$/i,
  java: /\.java$/i,
  c: /\.[ch]$/i,
  javascript: /\.m?js$/i,
  bash: /\.(sh|bash)$/i,
  php: /\.php$/i,
  html: /\.html?$/i,
  elixir: /\.(ex|exs)$/i,
  kotlin: /\.(kt|kts)$/i,
  zig: /\.zig$/i,
  crystal: /\.cr$/i,
  swift: /\.swift$/i,
  cobol: /\.(cob|cbl|cpy|cobol)$/i,
  csharp: /\.(cs|csx)$/i,
  groovy: /\.(groovy|gvy|gy|gradle)$/i,
  haml: /\.haml$/i,
  pascal: /\.(pas|pp|p|inc)$/i,
}.freeze

# Auto-generate Mode for languages that have parser + node_map but no existing Mode
Textbringer::TreeSitter::NodeMaps.available_languages.each do |language|
  next unless Textbringer::TreeSitterConfig.parser_available?(language)

  # Look for an existing Mode
  mode_name = MODE_LANGUAGE_MAP.key(language)&.to_s ||
              "#{language.to_s.split('_').map(&:capitalize).join}Mode"

  unless Textbringer.const_defined?(mode_name)
    # Auto-generate Mode if it does not exist
    pattern = LANGUAGE_FILE_PATTERNS[language]
    if pattern
      # Define named class via class_eval (to trigger inherited hook properly)
      Textbringer.class_eval <<~RUBY, __FILE__, __LINE__ + 1
        class #{mode_name} < ProgrammingMode
          self.file_name_pattern = #{pattern.inspect}

          # Define minimal indent_line (to allow line breaks)
          def indent_line
            # No-op by default
          end
        end
      RUBY
    end
  end
end

# Debug logging helper
def tree_sitter_debug(msg)
  return unless ENV["TEXTBRINGER_TREE_SITTER_DEBUG"] == "1"
  File.open("/tmp/tree_sitter_plugin.log", "a") { |f| f.puts "[#{Time.now}] #{msg}" }
end

# Enable tree-sitter on Modes that have an available parser and node_map
tree_sitter_debug "=== Enabling tree-sitter on modes ==="
tree_sitter_debug "available_languages: #{Textbringer::TreeSitter::NodeMaps.available_languages.inspect}"

MODE_LANGUAGE_MAP.each do |mode_name, language|
  next unless language

  parser_available = Textbringer::TreeSitterConfig.parser_available?(language)
  node_map = Textbringer::TreeSitter::NodeMaps.for(language)

  tree_sitter_debug "#{mode_name} (#{language}): parser=#{parser_available}, node_map=#{!!node_map}"

  next unless parser_available
  next unless node_map

  begin
    mode_class = Textbringer.const_get(mode_name)
    tree_sitter_debug "  found mode_class: #{mode_class}"

    # Skip if tree-sitter is already configured
    if mode_class.respond_to?(:tree_sitter_language) && mode_class.tree_sitter_language
      tree_sitter_debug "  already has tree_sitter_language: #{mode_class.tree_sitter_language}"
      next
    end

    # Extend with TreeSitterAdapter and call use_tree_sitter
    mode_class.extend(Textbringer::TreeSitterAdapter::ClassMethods)
    mode_class.use_tree_sitter(language)
    tree_sitter_debug "  enabled tree-sitter for #{mode_name}"
  rescue NameError => e
    tree_sitter_debug "  NameError: #{e.message}"
    # Ignore if Mode does not exist
  end
end

tree_sitter_debug "=== Done ==="
