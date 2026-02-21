# frozen_string_literal: true

require "test_helper"
require "textbringer/tree_sitter_config"
require "textbringer/tree_sitter/node_maps"
require "textbringer/tree_sitter_adapter"

class MarkdownIntegrationTest < Minitest::Test
  def setup
    Textbringer::Face.clear_all
    Textbringer::TreeSitterConfig.define_default_faces
    Textbringer::TreeSitter::NodeMaps.clear_custom_maps
    Textbringer::Window.has_colors = true
    Textbringer::CONFIG.clear
  end

  def test_user_node_map_can_be_registered
    # Register a user-defined node_map
    custom_map = {
      atx_h1_marker: :keyword,
      atx_heading: :keyword,
    }
    Textbringer::TreeSitter::NodeMaps.register(:markdown, custom_map)

    # Verify it was registered
    assert_includes Textbringer::TreeSitter::NodeMaps.available_languages, :markdown
    assert_equal :keyword, Textbringer::TreeSitter::NodeMaps.for(:markdown)[:atx_h1_marker]
  end

  def test_markdown_parser_available
    skip "Markdown parser not installed" unless File.exist?(markdown_parser_path)

    assert Textbringer::TreeSitterConfig.parser_available?(:markdown)
  end

  def test_markdown_mode_can_use_tree_sitter
    skip "Markdown parser not installed" unless File.exist?(markdown_parser_path)

    # Define MarkdownMode
    markdown_mode_class = Class.new(Textbringer::Mode)
    Textbringer.const_set(:MarkdownMode, markdown_mode_class) unless Textbringer.const_defined?(:MarkdownMode)

    mode_class = Textbringer::MarkdownMode

    # Register node_map
    Textbringer::TreeSitter::NodeMaps.register(:markdown, {
      atx_h1_marker: :keyword,
      atx_h2_marker: :keyword,
      atx_heading: :keyword,
    })

    # Extend with TreeSitterAdapter
    mode_class.extend(Textbringer::TreeSitterAdapter::ClassMethods)
    mode_class.use_tree_sitter(:markdown)

    # Verify it was configured
    assert mode_class.respond_to?(:tree_sitter_language)
    assert_equal :markdown, mode_class.tree_sitter_language
  end

  def test_markdown_custom_highlight_produces_highlights
    skip "Markdown parser not installed" unless File.exist?(markdown_parser_path)
    skip "tree_sitter gem not available" unless tree_sitter_available?

    # Register node_map
    Textbringer::TreeSitter::NodeMaps.register(:markdown, {
      atx_h1_marker: :keyword,
      atx_h2_marker: :keyword,
      atx_heading: :keyword,
    })

    # Define MarkdownMode and configure TreeSitterAdapter
    markdown_mode_class = Class.new(Textbringer::Mode) do
      extend Textbringer::TreeSitterAdapter::ClassMethods
      include Textbringer::TreeSitterAdapter::InstanceMethods
    end
    markdown_mode_class.use_tree_sitter(:markdown)

    # Create instance
    mode = markdown_mode_class.new

    # Prepare buffer and window
    buffer = Textbringer::MockBuffer.new
    buffer.content = "# Hello World\n\nThis is a test.\n"
    buffer.mode = mode
    window = Textbringer::Window.new(buffer)

    # Call custom_highlight
    mode.custom_highlight(window)

    # Check if highlights were generated
    highlight_on = window.instance_variable_get(:@highlight_on)
    highlight_off = window.instance_variable_get(:@highlight_off)

    # Debug output
    puts "\n=== Markdown Highlight Debug ==="
    puts "highlight_on keys: #{highlight_on.keys.inspect}"
    puts "highlight_off keys: #{highlight_off.keys.inspect}"

    # At least something should be highlighted
    refute_empty highlight_on, "Expected some highlights to be generated"
  end

  def test_markdown_heading_is_highlighted
    skip "Markdown parser not installed" unless File.exist?(markdown_parser_path)
    skip "tree_sitter gem not available" unless tree_sitter_available?

    # Define Face
    Textbringer::Face.define(:keyword, foreground: "yellow")

    # Register node_map (atx_h1_marker corresponds to the '#' part)
    Textbringer::TreeSitter::NodeMaps.register(:markdown, {
      atx_h1_marker: :keyword,
    })

    # Define MarkdownMode
    markdown_mode_class = Class.new(Textbringer::Mode) do
      extend Textbringer::TreeSitterAdapter::ClassMethods
      include Textbringer::TreeSitterAdapter::InstanceMethods
    end
    markdown_mode_class.use_tree_sitter(:markdown)

    mode = markdown_mode_class.new

    buffer = Textbringer::MockBuffer.new
    buffer.content = "# Hello\n"
    buffer.mode = mode
    window = Textbringer::Window.new(buffer)

    mode.custom_highlight(window)

    highlight_on = window.instance_variable_get(:@highlight_on)

    # There should be a highlight at position 0 (start of '#')
    assert highlight_on.key?(0), "Expected highlight at position 0 for '#'. Got: #{highlight_on.inspect}"
  end

  private

  def markdown_parser_path
    Textbringer::TreeSitterConfig.parser_path(:markdown)
  end

  def tree_sitter_available?
    require "tree_sitter"
    true
  rescue LoadError
    false
  end
end
