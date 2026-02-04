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
    # ユーザー定義の node_map を登録
    custom_map = {
      atx_h1_marker: :keyword,
      atx_heading: :keyword,
    }
    Textbringer::TreeSitter::NodeMaps.register(:markdown, custom_map)

    # 登録されたか確認
    assert_includes Textbringer::TreeSitter::NodeMaps.available_languages, :markdown
    assert_equal :keyword, Textbringer::TreeSitter::NodeMaps.for(:markdown)[:atx_h1_marker]
  end

  def test_markdown_parser_available
    skip "Markdown parser not installed" unless File.exist?(markdown_parser_path)

    assert Textbringer::TreeSitterConfig.parser_available?(:markdown)
  end

  def test_markdown_mode_can_use_tree_sitter
    skip "Markdown parser not installed" unless File.exist?(markdown_parser_path)

    # MarkdownMode を定義
    markdown_mode_class = Class.new(Textbringer::Mode)
    Textbringer.const_set(:MarkdownMode, markdown_mode_class) unless Textbringer.const_defined?(:MarkdownMode)

    mode_class = Textbringer::MarkdownMode

    # node_map を登録
    Textbringer::TreeSitter::NodeMaps.register(:markdown, {
      atx_h1_marker: :keyword,
      atx_h2_marker: :keyword,
      atx_heading: :keyword,
    })

    # TreeSitterAdapter を extend
    mode_class.extend(Textbringer::TreeSitterAdapter::ClassMethods)
    mode_class.use_tree_sitter(:markdown)

    # 設定されたか確認
    assert mode_class.respond_to?(:tree_sitter_language)
    assert_equal :markdown, mode_class.tree_sitter_language
  end

  def test_markdown_custom_highlight_produces_highlights
    skip "Markdown parser not installed" unless File.exist?(markdown_parser_path)
    skip "tree_sitter gem not available" unless tree_sitter_available?

    # node_map を登録
    Textbringer::TreeSitter::NodeMaps.register(:markdown, {
      atx_h1_marker: :keyword,
      atx_h2_marker: :keyword,
      atx_heading: :keyword,
    })

    # MarkdownMode を定義して TreeSitterAdapter を設定
    markdown_mode_class = Class.new(Textbringer::Mode) do
      extend Textbringer::TreeSitterAdapter::ClassMethods
      include Textbringer::TreeSitterAdapter::InstanceMethods
    end
    markdown_mode_class.use_tree_sitter(:markdown)

    # インスタンス作成
    mode = markdown_mode_class.new

    # バッファとウィンドウを準備
    buffer = Textbringer::MockBuffer.new
    buffer.content = "# Hello World\n\nThis is a test.\n"
    buffer.mode = mode
    window = Textbringer::Window.new(buffer)

    # custom_highlight を呼ぶ
    mode.custom_highlight(window)

    # ハイライトが生成されたか確認
    highlight_on = window.instance_variable_get(:@highlight_on)
    highlight_off = window.instance_variable_get(:@highlight_off)

    # デバッグ出力
    puts "\n=== Markdown Highlight Debug ==="
    puts "highlight_on keys: #{highlight_on.keys.inspect}"
    puts "highlight_off keys: #{highlight_off.keys.inspect}"

    # 少なくとも何かハイライトされているはず
    refute_empty highlight_on, "Expected some highlights to be generated"
  end

  def test_markdown_heading_is_highlighted
    skip "Markdown parser not installed" unless File.exist?(markdown_parser_path)
    skip "tree_sitter gem not available" unless tree_sitter_available?

    # Face を定義
    Textbringer::Face.define(:keyword, foreground: "yellow")

    # node_map を登録（atx_h1_marker は # の部分）
    Textbringer::TreeSitter::NodeMaps.register(:markdown, {
      atx_h1_marker: :keyword,
    })

    # MarkdownMode を定義
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

    # position 0 (# の開始位置) にハイライトがあるはず
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
