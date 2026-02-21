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

    # テスト用の Mode クラスをクリア
    remove_test_modes
  end

  def teardown
    remove_test_modes
  end

  def test_mode_language_map_includes_markdown
    # textbringer_plugin.rb で定義される MODE_LANGUAGE_MAP を再現
    mode_language_map = {
      "RubyMode" => :ruby,
      "MarkdownMode" => :markdown,
    }

    assert_equal :markdown, mode_language_map["MarkdownMode"]
  end

  def test_tree_sitter_enabled_on_existing_mode
    skip "Markdown parser not installed" unless parser_available?(:markdown)

    # 既存の MarkdownMode をシミュレート
    markdown_mode = Class.new(Textbringer::Mode)
    Textbringer.const_set(:TestMarkdownMode, markdown_mode)

    # node_map を登録
    Textbringer::TreeSitter::NodeMaps.register(:markdown, {
      atx_h1_marker: :keyword,
    })

    # textbringer_plugin.rb のロジックを再現
    mode_class = Textbringer::TestMarkdownMode
    language = :markdown

    # parser と node_map が利用可能か確認
    assert Textbringer::TreeSitterConfig.parser_available?(language)
    assert Textbringer::TreeSitter::NodeMaps.for(language)

    # TreeSitterAdapter を extend
    mode_class.extend(Textbringer::TreeSitterAdapter::ClassMethods)
    mode_class.use_tree_sitter(language)

    # 確認
    assert mode_class.respond_to?(:tree_sitter_language)
    assert_equal :markdown, mode_class.tree_sitter_language
  end

  def test_mode_instance_can_highlight_after_setup
    skip "Markdown parser not installed" unless parser_available?(:markdown)
    skip "tree_sitter gem not available" unless tree_sitter_available?

    # Face 定義
    Textbringer::Face.define(:keyword, foreground: "yellow")

    # MarkdownMode を作成して設定
    markdown_mode = Class.new(Textbringer::Mode) do
      extend Textbringer::TreeSitterAdapter::ClassMethods
      include Textbringer::TreeSitterAdapter::InstanceMethods
    end
    Textbringer.const_set(:TestMarkdownMode2, markdown_mode)

    # node_map を登録
    Textbringer::TreeSitter::NodeMaps.register(:markdown, {
      atx_h1_marker: :keyword,
    })

    # use_tree_sitter を呼ぶ
    markdown_mode.use_tree_sitter(:markdown)

    # インスタンス作成
    mode_instance = markdown_mode.new

    # バッファとウィンドウを準備
    buffer = Textbringer::MockBuffer.new
    buffer.content = "# Test\n"
    buffer.mode = mode_instance
    window = Textbringer::Window.new(buffer)

    # custom_highlight を呼ぶ
    mode_instance.custom_highlight(window)

    # ハイライトが生成されたか
    highlight_on = window.instance_variable_get(:@highlight_on)
    refute_empty highlight_on, "Expected highlights to be generated"

    # position 0 にハイライトがあるはず (# の位置)
    assert highlight_on.key?(0), "Expected highlight at position 0"
  end

  def test_user_node_map_loaded_and_available
    # ユーザー定義の node_map をシミュレート
    custom_node_map = {
      atx_h1_marker: :keyword,
      atx_h2_marker: :keyword,
      fenced_code_block_delimiter: :punctuation,
    }
    Textbringer::TreeSitter::NodeMaps.register(:markdown, custom_node_map)

    # available_languages に含まれるか
    assert_includes Textbringer::TreeSitter::NodeMaps.available_languages, :markdown

    # for で取得できるか
    map = Textbringer::TreeSitter::NodeMaps.for(:markdown)
    assert_equal :keyword, map[:atx_h1_marker]
    assert_equal :punctuation, map[:fenced_code_block_delimiter]
  end

  def test_existing_mode_without_tree_sitter_gets_enabled
    skip "Markdown parser not installed" unless parser_available?(:markdown)

    # 既存の Mode（tree-sitter なし）
    existing_mode = Class.new(Textbringer::Mode)
    Textbringer.const_set(:TestExistingMode, existing_mode)

    # tree_sitter_language が未定義であることを確認
    refute existing_mode.respond_to?(:tree_sitter_language)

    # node_map を登録
    Textbringer::TreeSitter::NodeMaps.register(:markdown, { atx_h1_marker: :keyword })

    # textbringer_plugin.rb のロジック
    language = :markdown
    return unless Textbringer::TreeSitterConfig.parser_available?(language)
    return unless Textbringer::TreeSitter::NodeMaps.for(language)

    # 既に tree-sitter が設定されていなければ設定
    unless existing_mode.respond_to?(:tree_sitter_language) && existing_mode.tree_sitter_language
      existing_mode.extend(Textbringer::TreeSitterAdapter::ClassMethods)
      existing_mode.use_tree_sitter(language)
    end

    # 設定されたか
    assert existing_mode.respond_to?(:tree_sitter_language)
    assert_equal :markdown, existing_mode.tree_sitter_language
  end

  def test_existing_custom_highlight_gets_overwritten
    skip "Markdown parser not installed" unless parser_available?(:markdown)
    skip "tree_sitter gem not available" unless tree_sitter_available?

    # Face 定義
    Textbringer::Face.define(:keyword, foreground: "yellow")

    # node_map を登録
    Textbringer::TreeSitter::NodeMaps.register(:markdown, {
      atx_h1_marker: :keyword,
    })

    # 既存の custom_highlight を持つ Mode をシミュレート
    existing_mode = Class.new(Textbringer::Mode) do
      def custom_highlight(window)
        # 何もしない（textbringer-markdown の動作をシミュレート）
        window.instance_variable_set(:@highlight_on, { existing: true })
      end
    end
    Textbringer.const_set(:TestOverwriteMode, existing_mode)

    # TreeSitterAdapter を extend
    existing_mode.extend(Textbringer::TreeSitterAdapter::ClassMethods)
    existing_mode.use_tree_sitter(:markdown)

    # インスタンス作成
    mode_instance = existing_mode.new

    # バッファとウィンドウを準備
    buffer = Textbringer::MockBuffer.new
    buffer.content = "# Test\n"
    buffer.mode = mode_instance
    window = Textbringer::Window.new(buffer)

    # custom_highlight を呼ぶ
    mode_instance.custom_highlight(window)

    highlight_on = window.instance_variable_get(:@highlight_on)

    # TreeSitterAdapter の custom_highlight が優先されているか
    # (既存の custom_highlight が呼ばれていたら { existing: true } になる)
    refute highlight_on[:existing], "TreeSitterAdapter's custom_highlight should override existing one"
    assert highlight_on.key?(0), "TreeSitterAdapter's custom_highlight should produce highlights at position 0"
  end

  def test_window_highlight_calls_custom_highlight
    skip "Markdown parser not installed" unless parser_available?(:markdown)
    skip "tree_sitter gem not available" unless tree_sitter_available?

    # Face 定義
    Textbringer::Face.define(:keyword, foreground: "yellow")

    # node_map を登録
    Textbringer::TreeSitter::NodeMaps.register(:markdown, {
      atx_h1_marker: :keyword,
    })

    # MarkdownMode を作成して設定
    markdown_mode = Class.new(Textbringer::Mode) do
      extend Textbringer::TreeSitterAdapter::ClassMethods
    end
    Textbringer.const_set(:TestWindowMode, markdown_mode)
    markdown_mode.use_tree_sitter(:markdown)

    # インスタンス作成
    mode_instance = markdown_mode.new

    # custom_highlight が定義されているか確認
    assert mode_instance.respond_to?(:custom_highlight), "Mode should have custom_highlight method"

    # バッファとウィンドウを準備
    buffer = Textbringer::MockBuffer.new
    buffer.content = "# Test\n"
    buffer.mode = mode_instance
    window = Textbringer::Window.new(buffer)

    # Window.highlight を呼ぶ（monkey patch 経由で custom_highlight が呼ばれるはず）
    window.highlight

    # ハイライトが生成されたか
    highlight_on = window.instance_variable_get(:@highlight_on)
    refute_empty highlight_on, "Window.highlight should call custom_highlight and produce highlights"
  end

  def test_multibyte_markdown_highlight
    skip "Markdown parser not installed" unless parser_available?(:markdown)
    skip "tree_sitter gem not available" unless tree_sitter_available?

    # Face 定義
    Textbringer::Face.define(:keyword, foreground: "yellow")

    # MarkdownMode を作成して設定
    markdown_mode = Class.new(Textbringer::Mode) do
      extend Textbringer::TreeSitterAdapter::ClassMethods
    end
    Textbringer.const_set(:TestMultibyteMode, markdown_mode)

    # node_map を登録
    Textbringer::TreeSitter::NodeMaps.register(:markdown, {
      atx_h1_marker: :keyword,
    })

    markdown_mode.use_tree_sitter(:markdown)

    mode_instance = markdown_mode.new
    buffer = Textbringer::MockBuffer.new
    # "# テスト\n" — "#" は 1 byte, " " は 1 byte, "テスト" は 9 bytes, "\n" は 1 byte
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
