# frozen_string_literal: true

require "test_helper"
require "textbringer/tree_sitter_config"
require "textbringer/tree_sitter/node_maps"

# NodeMap のバリデーションをテストするヘルパー
module NodeMapValidator
  # Language から利用可能なノードタイプを取得
  #
  # @param language_name [String, Symbol] 言語名
  # @param lib_path [String] parser の .dylib/.so ファイルパス
  # @return [Set<String>] ノードタイプの集合
  def self.available_node_types(language_name, lib_path)
    require "tree_sitter"
    require "set"

    return Set.new unless File.exist?(lib_path)

    language = TreeSitter::Language.load(language_name.to_s, lib_path)
    count = language.symbol_count

    node_types = Set.new

    (0...count).each do |i|
      type = language.symbol_type(i)
      # regular symbols が named node types
      # anonymous symbols は "def", "{" などのリテラルだが、色付けに使われる
      # auxiliary symbols は内部用の補助ノード
      if type == :regular || type == :anonymous
        name = language.symbol_name(i)
        node_types.add(name)
      end
    end

    node_types
  end

  # NodeMap が文法に存在しないノードタイプを含んでいないか検証
  #
  # @param language [Symbol] 言語名
  # @param node_map [Hash] NodeMap
  # @param lib_path [String] parser の .dylib/.so ファイルパス
  # @return [Hash] { valid: bool, invalid: Set<String> }
  def self.validate(language, node_map, lib_path)
    return { valid: true, invalid: Set.new, skipped: true } unless File.exist?(lib_path)

    valid_types = available_node_types(language, lib_path)
    defined_types = Set.new(node_map.keys.map(&:to_s))

    # NodeMap にあるが文法に存在しないノード
    # これは typo や古い定義の可能性がある
    invalid = defined_types - valid_types

    { valid: invalid.empty?, invalid: invalid, skipped: false }
  end
end

class NodeMapValidatorTest < Minitest::Test
  def parser_path(language)
    platform = Textbringer::TreeSitterConfig.platform
    ext = Textbringer::TreeSitterConfig.dylib_ext
    File.expand_path("../../../../parsers/#{platform}/libtree-sitter-#{language}#{ext}", __FILE__)
  end

  def test_ruby_node_map_validity
    skip "Parser not available on this platform" unless Textbringer::TreeSitterConfig.parser_available?("ruby")

    node_map = Textbringer::TreeSitter::NodeMaps::RUBY
    result = NodeMapValidator.validate(:ruby, node_map, parser_path("ruby"))

    skip "Parser not found" if result[:skipped]

    # 不正なノードタイプがある場合、詳細を表示
    unless result[:valid]
      message = "Invalid node types found in RUBY NodeMap:\n"
      result[:invalid].sort.each { |type| message += "  - #{type}\n" }
      message += "\nThese node types do not exist in the Ruby grammar.\n"
      message += "They may be typos or deprecated. Consider removing them."
      flunk(message)
    end

    assert result[:valid], "All node types in RUBY NodeMap should exist in the grammar"
  end

  def test_hcl_node_map_validity
    skip "Parser not available on this platform" unless Textbringer::TreeSitterConfig.parser_available?("hcl")

    node_map = Textbringer::TreeSitter::NodeMaps::HCL
    result = NodeMapValidator.validate(:hcl, node_map, parser_path("hcl"))

    skip "Parser not found" if result[:skipped]

    unless result[:valid]
      message = "Invalid node types found in HCL NodeMap:\n"
      result[:invalid].sort.each { |type| message += "  - #{type}\n" }
      message += "\nThese node types do not exist in the HCL grammar.\n"
      message += "They may be typos or deprecated. Consider removing them."
      flunk(message)
    end

    assert result[:valid], "All node types in HCL NodeMap should exist in the grammar"
  end

  def test_bash_node_map_validity
    skip "Parser not available on this platform" unless Textbringer::TreeSitterConfig.parser_available?("bash")

    node_map = Textbringer::TreeSitter::NodeMaps::BASH
    result = NodeMapValidator.validate(:bash, node_map, parser_path("bash"))

    skip "Parser not found" if result[:skipped]

    unless result[:valid]
      message = "Invalid node types found in BASH NodeMap:\n"
      result[:invalid].sort.each { |type| message += "  - #{type}\n" }
      flunk(message)
    end

    assert result[:valid]
  end

  def test_python_node_map_validity
    skip "Parser not available on this platform" unless Textbringer::TreeSitterConfig.parser_available?("python")

    node_map = Textbringer::TreeSitter::NodeMaps::PYTHON
    result = NodeMapValidator.validate(:python, node_map, parser_path("python"))

    skip "Parser not found" if result[:skipped]

    unless result[:valid]
      message = "Invalid node types found in PYTHON NodeMap:\n"
      result[:invalid].sort.each { |type| message += "  - #{type}\n" }
      flunk(message)
    end

    assert result[:valid]
  end

  def test_javascript_node_map_validity
    skip "Parser not available on this platform" unless Textbringer::TreeSitterConfig.parser_available?("javascript")

    node_map = Textbringer::TreeSitter::NodeMaps::JAVASCRIPT
    result = NodeMapValidator.validate(:javascript, node_map, parser_path("javascript"))

    skip "Parser not found" if result[:skipped]

    unless result[:valid]
      message = "Invalid node types found in JAVASCRIPT NodeMap:\n"
      result[:invalid].sort.each { |type| message += "  - #{type}\n" }
      flunk(message)
    end

    assert result[:valid]
  end

  # 各言語の主要ノードタイプが実際に文法に存在することを確認
  def test_ruby_essential_nodes_exist
    skip "Parser not available" unless Textbringer::TreeSitterConfig.parser_available?("ruby")

    available = NodeMapValidator.available_node_types(:ruby, parser_path("ruby"))
    skip "Parser not found" if available.empty?

    # Ruby grammar に必ず存在すべきノードタイプ
    essential_nodes = %w[
      comment
      string
      identifier
      integer
      method
      class
      module
      if
      for
      while
    ]

    essential_nodes.each do |node|
      assert available.include?(node), "Essential node '#{node}' should exist in Ruby grammar"
    end
  end

  def test_hcl_essential_nodes_exist
    skip "Parser not available" unless Textbringer::TreeSitterConfig.parser_available?("hcl")

    available = NodeMapValidator.available_node_types(:hcl, parser_path("hcl"))
    skip "Parser not found" if available.empty?

    # HCL grammar に必ず存在すべきノードタイプ
    essential_nodes = %w[
      comment
      identifier
      function_call
      attribute
      block
      for_expr
      numeric_literal
    ]

    essential_nodes.each do |node|
      assert available.include?(node), "Essential node '#{node}' should exist in HCL grammar"
    end
  end

  # Anonymous node vs Named node の区別をテスト
  def test_anonymous_vs_named_nodes
    skip "Parser not available" unless Textbringer::TreeSitterConfig.parser_available?("ruby")

    lib_path = parser_path("ruby")
    skip "Parser not found" unless File.exist?(lib_path)

    require "tree_sitter"
    language = TreeSitter::Language.load("ruby", lib_path)

    # "def" は anonymous symbol (symbol_type == :anonymous)
    # "method" は regular symbol (symbol_type == :regular)

    def_found = false
    method_found = false

    (0...language.symbol_count).each do |i|
      name = language.symbol_name(i)
      type = language.symbol_type(i)

      if name == "def"
        def_found = true
        assert_equal :anonymous, type, "'def' should be an anonymous symbol"
      elsif name == "method"
        method_found = true
        assert_equal :regular, type, "'method' should be a regular symbol"
      end
    end

    assert def_found, "'def' symbol should exist"
    assert method_found, "'method' symbol should exist"
  end
end
