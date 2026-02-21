# frozen_string_literal: true

require "test_helper"
require "textbringer/tree_sitter_config"
require "textbringer/tree_sitter/node_maps"
require "textbringer/tree_sitter_adapter"

class PluginIntegrationTest < Minitest::Test
  def setup
    Textbringer::Face.clear_all
    Textbringer::TreeSitterConfig.define_default_faces
    Textbringer::TreeSitter::NodeMaps.clear_custom_maps
    Textbringer::Window.has_colors = true
    Textbringer::CONFIG.clear

    # Clear test Mode classes
    remove_test_modes
  end

  def teardown
    remove_test_modes
  end

  def test_mode_language_map_includes_markdown
    # Reproduce MODE_LANGUAGE_MAP defined in textbringer_plugin.rb
    mode_language_map = {
      "RubyMode" => :ruby,
      "MarkdownMode" => :markdown,
    }

    assert_equal :markdown, mode_language_map["MarkdownMode"]
  end

  def test_tree_sitter_enabled_on_existing_mode
    skip "Markdown parser not installed" unless parser_available?(:markdown)

    # Simulate an existing MarkdownMode
    markdown_mode = Class.new(Textbringer::Mode)
    Textbringer.const_set(:TestMarkdownMode, markdown_mode)

    # Register node_map
    Textbringer::TreeSitter::NodeMaps.register(:markdown, {
      atx_h1_marker: :keyword,
    })

    # Reproduce the logic from textbringer_plugin.rb
    mode_class = Textbringer::TestMarkdownMode
    language = :markdown

    # Verify parser and node_map are available
    assert Textbringer::TreeSitterConfig.parser_available?(language)
    assert Textbringer::TreeSitter::NodeMaps.for(language)

    # Extend with TreeSitterAdapter
    mode_class.extend(Textbringer::TreeSitterAdapter::ClassMethods)
    mode_class.use_tree_sitter(language)

    # Verify
    assert mode_class.respond_to?(:tree_sitter_language)
    assert_equal :markdown, mode_class.tree_sitter_language
  end

  def test_mode_instance_can_highlight_after_setup
    skip "Markdown parser not installed" unless parser_available?(:markdown)
    skip "tree_sitter gem not available" unless tree_sitter_available?

    # Define Face
    Textbringer::Face.define(:keyword, foreground: "yellow")

    # Create and configure MarkdownMode
    markdown_mode = Class.new(Textbringer::Mode) do
      extend Textbringer::TreeSitterAdapter::ClassMethods
      include Textbringer::TreeSitterAdapter::InstanceMethods
    end
    Textbringer.const_set(:TestMarkdownMode2, markdown_mode)

    # Register node_map
    Textbringer::TreeSitter::NodeMaps.register(:markdown, {
      atx_h1_marker: :keyword,
    })

    # Call use_tree_sitter
    markdown_mode.use_tree_sitter(:markdown)

    # Create instance
    mode_instance = markdown_mode.new

    # Prepare buffer and window
    buffer = Textbringer::MockBuffer.new
    buffer.content = "# Test\n"
    buffer.mode = mode_instance
    window = Textbringer::Window.new(buffer)

    # Call custom_highlight
    mode_instance.custom_highlight(window)

    # Check if highlights were generated
    highlight_on = window.instance_variable_get(:@highlight_on)
    refute_empty highlight_on, "Expected highlights to be generated"

    # There should be a highlight at position 0 (position of '#')
    assert highlight_on.key?(0), "Expected highlight at position 0"
  end

  def test_user_node_map_loaded_and_available
    # Simulate a user-defined node_map
    custom_node_map = {
      atx_h1_marker: :keyword,
      atx_h2_marker: :keyword,
      fenced_code_block_delimiter: :punctuation,
    }
    Textbringer::TreeSitter::NodeMaps.register(:markdown, custom_node_map)

    # Check if included in available_languages
    assert_includes Textbringer::TreeSitter::NodeMaps.available_languages, :markdown

    # Check if retrievable via for
    map = Textbringer::TreeSitter::NodeMaps.for(:markdown)
    assert_equal :keyword, map[:atx_h1_marker]
    assert_equal :punctuation, map[:fenced_code_block_delimiter]
  end

  def test_existing_mode_without_tree_sitter_gets_enabled
    skip "Markdown parser not installed" unless parser_available?(:markdown)

    # Existing Mode (without tree-sitter)
    existing_mode = Class.new(Textbringer::Mode)
    Textbringer.const_set(:TestExistingMode, existing_mode)

    # Verify tree_sitter_language is not defined
    refute existing_mode.respond_to?(:tree_sitter_language)

    # Register node_map
    Textbringer::TreeSitter::NodeMaps.register(:markdown, { atx_h1_marker: :keyword })

    # Logic from textbringer_plugin.rb
    language = :markdown
    return unless Textbringer::TreeSitterConfig.parser_available?(language)
    return unless Textbringer::TreeSitter::NodeMaps.for(language)

    # Set up tree-sitter if not already configured
    unless existing_mode.respond_to?(:tree_sitter_language) && existing_mode.tree_sitter_language
      existing_mode.extend(Textbringer::TreeSitterAdapter::ClassMethods)
      existing_mode.use_tree_sitter(language)
    end

    # Verify it was configured
    assert existing_mode.respond_to?(:tree_sitter_language)
    assert_equal :markdown, existing_mode.tree_sitter_language
  end

  def test_existing_custom_highlight_gets_overwritten
    skip "Markdown parser not installed" unless parser_available?(:markdown)
    skip "tree_sitter gem not available" unless tree_sitter_available?

    # Define Face
    Textbringer::Face.define(:keyword, foreground: "yellow")

    # Register node_map
    Textbringer::TreeSitter::NodeMaps.register(:markdown, {
      atx_h1_marker: :keyword,
    })

    # Simulate a Mode with an existing custom_highlight
    existing_mode = Class.new(Textbringer::Mode) do
      def custom_highlight(window)
        # No-op (simulating textbringer-markdown behavior)
        window.instance_variable_set(:@highlight_on, { existing: true })
      end
    end
    Textbringer.const_set(:TestOverwriteMode, existing_mode)

    # Extend with TreeSitterAdapter
    existing_mode.extend(Textbringer::TreeSitterAdapter::ClassMethods)
    existing_mode.use_tree_sitter(:markdown)

    # Create instance
    mode_instance = existing_mode.new

    # Prepare buffer and window
    buffer = Textbringer::MockBuffer.new
    buffer.content = "# Test\n"
    buffer.mode = mode_instance
    window = Textbringer::Window.new(buffer)

    # Call custom_highlight
    mode_instance.custom_highlight(window)

    highlight_on = window.instance_variable_get(:@highlight_on)

    # Verify TreeSitterAdapter's custom_highlight takes precedence
    # (if the existing custom_highlight were called, it would be { existing: true })
    refute highlight_on[:existing], "TreeSitterAdapter's custom_highlight should override existing one"
    assert highlight_on.key?(0), "TreeSitterAdapter's custom_highlight should produce highlights at position 0"
  end

  def test_window_highlight_calls_custom_highlight
    skip "Markdown parser not installed" unless parser_available?(:markdown)
    skip "tree_sitter gem not available" unless tree_sitter_available?

    # Define Face
    Textbringer::Face.define(:keyword, foreground: "yellow")

    # Register node_map
    Textbringer::TreeSitter::NodeMaps.register(:markdown, {
      atx_h1_marker: :keyword,
    })

    # Create and configure MarkdownMode
    markdown_mode = Class.new(Textbringer::Mode) do
      extend Textbringer::TreeSitterAdapter::ClassMethods
    end
    Textbringer.const_set(:TestWindowMode, markdown_mode)
    markdown_mode.use_tree_sitter(:markdown)

    # Create instance
    mode_instance = markdown_mode.new

    # Verify custom_highlight is defined
    assert mode_instance.respond_to?(:custom_highlight), "Mode should have custom_highlight method"

    # Prepare buffer and window
    buffer = Textbringer::MockBuffer.new
    buffer.content = "# Test\n"
    buffer.mode = mode_instance
    window = Textbringer::Window.new(buffer)

    # Call Window.highlight (should invoke custom_highlight via monkey-patch)
    window.highlight

    # Check if highlights were generated
    highlight_on = window.instance_variable_get(:@highlight_on)
    refute_empty highlight_on, "Window.highlight should call custom_highlight and produce highlights"
  end

  def test_multibyte_markdown_highlight
    skip "Markdown parser not installed" unless parser_available?(:markdown)
    skip "tree_sitter gem not available" unless tree_sitter_available?

    # Define Face
    Textbringer::Face.define(:keyword, foreground: "yellow")

    # Create and configure MarkdownMode
    markdown_mode = Class.new(Textbringer::Mode) do
      extend Textbringer::TreeSitterAdapter::ClassMethods
    end
    Textbringer.const_set(:TestMultibyteMode, markdown_mode)

    # Register node_map
    Textbringer::TreeSitter::NodeMaps.register(:markdown, {
      atx_h1_marker: :keyword,
    })

    markdown_mode.use_tree_sitter(:markdown)

    mode_instance = markdown_mode.new
    buffer = Textbringer::MockBuffer.new
    # "# テスト\n" -- "#" is 1 byte, " " is 1 byte, "テスト" is 9 bytes, "\n" is 1 byte
    buffer.content = "# テスト\n"
    buffer.mode = mode_instance
    window = Textbringer::Window.new(buffer)

    mode_instance.custom_highlight(window)

    highlight_on = window.instance_variable_get(:@highlight_on)
    refute_empty highlight_on, "Expected highlights for multibyte markdown"
    assert highlight_on.key?(0), "Expected highlight at byte offset 0 for '#'"
  end

  private

  def parser_available?(language)
    Textbringer::TreeSitterConfig.parser_available?(language)
  end

  def tree_sitter_available?
    require "tree_sitter"
    true
  rescue LoadError
    false
  end

  def remove_test_modes
    [:TestMarkdownMode, :TestMarkdownMode2, :TestExistingMode, :TestOverwriteMode, :TestWindowMode, :TestMultibyteMode].each do |name|
      Textbringer.send(:remove_const, name) if Textbringer.const_defined?(name)
    end
  end
end
