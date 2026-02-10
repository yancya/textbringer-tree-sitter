# frozen_string_literal: true

# Textbringer plugin エントリポイント
# Textbringer がプラグインを自動ロードする際に読み込まれる

# tree_sitter gem を先に require して namespace 衝突を防ぐ
# (Textbringer::TreeSitter より先に ::TreeSitter を定義)
begin
  require "tree_sitter"
rescue LoadError
  # tree_sitter gem がない場合は無視（parser なしで動作）
end

require "textbringer/tree_sitter/version"
require "textbringer/tree_sitter_config"
require "textbringer/tree_sitter/node_maps"
require "textbringer/tree_sitter_adapter"

# デフォルトの Face を定義
Textbringer::TreeSitterConfig.define_default_faces

# ユーザー定義の node_maps を読み込む
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

# 既存 Mode → 言語 のマッピング
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
}.freeze

# 言語 → ファイルパターン（自動 Mode 生成用）
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
}.freeze

# parser + node_map がある言語で、Mode がなければ自動生成
Textbringer::TreeSitter::NodeMaps.available_languages.each do |language|
  next unless Textbringer::TreeSitterConfig.parser_available?(language)

  # 既存の Mode を探す
  mode_name = MODE_LANGUAGE_MAP.key(language)&.to_s ||
              "#{language.to_s.split('_').map(&:capitalize).join}Mode"

  unless Textbringer.const_defined?(mode_name)
    # Mode が存在しない場合は自動生成
    pattern = LANGUAGE_FILE_PATTERNS[language]
    if pattern
      # class_eval で名前付きクラスを定義（inherited フック対策）
      Textbringer.class_eval <<~RUBY, __FILE__, __LINE__ + 1
        class #{mode_name} < ProgrammingMode
          self.file_name_pattern = #{pattern.inspect}

          # 最低限の indent_line を定義（改行できるように）
          def indent_line
            # デフォルトは何もしない
          end
        end
      RUBY
    end
  end
end

# デバッグログ用
def tree_sitter_debug(msg)
  return unless ENV["TEXTBRINGER_TREE_SITTER_DEBUG"] == "1"
  File.open("/tmp/tree_sitter_plugin.log", "a") { |f| f.puts "[#{Time.now}] #{msg}" }
end

# 利用可能な parser と node_map がある Mode に tree-sitter を有効化
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

    # 既に tree-sitter が設定されていればスキップ
    if mode_class.respond_to?(:tree_sitter_language) && mode_class.tree_sitter_language
      tree_sitter_debug "  already has tree_sitter_language: #{mode_class.tree_sitter_language}"
      next
    end

    # TreeSitterAdapter を extend して use_tree_sitter を呼ぶ
    mode_class.extend(Textbringer::TreeSitterAdapter::ClassMethods)
    mode_class.use_tree_sitter(language)
    tree_sitter_debug "  enabled tree-sitter for #{mode_name}"
  rescue NameError => e
    tree_sitter_debug "  NameError: #{e.message}"
    # Mode が存在しない場合は無視
  end
end

tree_sitter_debug "=== Done ==="
