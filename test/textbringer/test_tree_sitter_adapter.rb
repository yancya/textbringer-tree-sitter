# frozen_string_literal: true

require "test_helper"
require "textbringer/tree_sitter_config"
require "textbringer/tree_sitter/node_maps"
require "textbringer/tree_sitter_adapter"

class TreeSitterAdapterTest < Minitest::Test
  def setup
    Textbringer::Face.clear_all
    Textbringer::TreeSitterConfig.define_default_faces
    Textbringer::CONFIG.clear
    Textbringer::TreeSitter::NodeMaps.clear_custom_maps
  end

  # use_tree_sitter クラスメソッド
  def test_use_tree_sitter_class_method
    klass = Class.new(Textbringer::Mode) do
      extend Textbringer::TreeSitterAdapter::ClassMethods
      use_tree_sitter :ruby
    end

    mode = klass.new
    assert_equal :ruby, mode.tree_sitter_language
  end

  def test_use_tree_sitter_includes_instance_methods
    klass = Class.new(Textbringer::Mode) do
      extend Textbringer::TreeSitterAdapter::ClassMethods
      use_tree_sitter :ruby
    end

    mode = klass.new
    assert mode.respond_to?(:custom_highlight)
    assert mode.respond_to?(:tree_sitter_language)
  end

  # custom_highlight の初期化
  def test_custom_highlight_initializes_highlight_hashes
    mode = create_test_mode(:ruby)
    window = Textbringer::Window.new

    mode.custom_highlight(window)

    assert_kind_of Hash, window.highlight_on
    assert_kind_of Hash, window.highlight_off
  end

  # colors 無効時の early return
  def test_custom_highlight_returns_early_when_colors_disabled
    Textbringer::CONFIG[:colors] = false

    mode = create_test_mode(:ruby)
    window = Textbringer::Window.new

    # エラーなく完了することを確認
    mode.custom_highlight(window)

    assert_equal({}, window.highlight_on)
  end

  def test_custom_highlight_works_when_colors_enabled
    Textbringer::CONFIG[:colors] = true

    mode = create_test_mode(:ruby)
    window = Textbringer::Window.new

    # parser がなくてもエラーにならない
    mode.custom_highlight(window)

    # parser がないのでハイライトはされない
    assert_kind_of Hash, window.highlight_on
  end

  # syntax_highlight 無効時の early return
  def test_custom_highlight_returns_early_when_syntax_highlight_disabled
    Textbringer::CONFIG[:colors] = true
    Textbringer::CONFIG[:syntax_highlight] = false

    mode = create_test_mode(:ruby)
    window = Textbringer::Window.new

    mode.custom_highlight(window)

    assert_equal({}, window.highlight_on)
  end

  # node_type_to_face マッピング
  def test_node_type_to_face_returns_correct_face
    mode = create_test_mode(:ruby)

    assert_equal :keyword, mode.send(:node_type_to_face, :def)
    assert_equal :comment, mode.send(:node_type_to_face, :comment)
    assert_equal :string, mode.send(:node_type_to_face, :string_content)
    assert_equal :number, mode.send(:node_type_to_face, :integer)
  end

  def test_node_type_to_face_returns_nil_for_unknown
    mode = create_test_mode(:ruby)

    assert_nil mode.send(:node_type_to_face, :unknown_node_type)
  end

  # レベル制御
  def test_enabled_faces_at_level_1
    Textbringer::CONFIG[:tree_sitter_highlight_level] = 1

    mode = create_test_mode(:ruby)
    faces = mode.send(:enabled_faces)

    assert_includes faces, :comment
    assert_includes faces, :string
    refute_includes faces, :keyword
    refute_includes faces, :function_name
  end

  def test_enabled_faces_at_level_2
    Textbringer::CONFIG[:tree_sitter_highlight_level] = 2

    mode = create_test_mode(:ruby)
    faces = mode.send(:enabled_faces)

    assert_includes faces, :comment
    assert_includes faces, :string
    assert_includes faces, :keyword
    assert_includes faces, :type
    assert_includes faces, :constant
    refute_includes faces, :function_name
  end

  def test_enabled_faces_at_level_3_default
    # level が設定されていない場合はデフォルト (3)
    mode = create_test_mode(:ruby)
    faces = mode.send(:enabled_faces)

    assert_includes faces, :comment
    assert_includes faces, :string
    assert_includes faces, :keyword
    assert_includes faces, :function_name
    assert_includes faces, :variable
    assert_includes faces, :number
    refute_includes faces, :operator
    refute_includes faces, :punctuation
  end

  def test_enabled_faces_at_level_4
    Textbringer::CONFIG[:tree_sitter_highlight_level] = 4

    mode = create_test_mode(:ruby)
    faces = mode.send(:enabled_faces)

    assert_includes faces, :comment
    assert_includes faces, :string
    assert_includes faces, :keyword
    assert_includes faces, :function_name
    assert_includes faces, :operator
    assert_includes faces, :punctuation
    assert_includes faces, :builtin
  end

  def test_node_type_to_face_respects_level
    Textbringer::CONFIG[:tree_sitter_highlight_level] = 1

    mode = create_test_mode(:ruby)

    # Level 1 では comment と string のみ有効
    assert_equal :comment, mode.send(:node_type_to_face, :comment)
    assert_equal :string, mode.send(:node_type_to_face, :string_content)
    # keyword は Level 2 以上なので nil
    assert_nil mode.send(:node_type_to_face, :def)
  end

  # カスタム enabled_features 設定
  def test_enabled_features_custom
    Textbringer::CONFIG[:tree_sitter_enabled_features] = %i[comment keyword]

    mode = create_test_mode(:ruby)
    faces = mode.send(:enabled_faces)

    assert_includes faces, :comment
    assert_includes faces, :keyword
    refute_includes faces, :string
    refute_includes faces, :function_name
  end

  # HCL の Rouge 問題解決確認
  def test_hcl_for_in_recognized_as_keyword
    mode = create_test_mode(:hcl)

    # Rouge では Name.Other になっていた for, in がキーワードに
    assert_equal :keyword, mode.send(:node_type_to_face, :for)
    assert_equal :keyword, mode.send(:node_type_to_face, :in)
  end

  def test_hcl_function_call_recognized
    mode = create_test_mode(:hcl)

    # Rouge では認識されなかった function_call
    assert_equal :function_name, mode.send(:node_type_to_face, :function_call)
  end

  # Window モンキーパッチの確認
  def test_window_has_highlight_method
    assert Textbringer::Window.method_defined?(:highlight)
  end

  # Multibyte character offset handling
  def test_multibyte_character_offsets
    Textbringer::CONFIG[:colors] = true
    Textbringer::CONFIG[:tree_sitter_highlight_level] = 4

    mode = create_test_mode(:ruby)
    window = Textbringer::Window.new

    # Ruby code with multibyte characters
    # "日本語" is 3 characters but 9 bytes (3 bytes per character in UTF-8)
    # The keyword "def" should be highlighted correctly even after multibyte chars
    code_with_multibyte = "# 日本語コメント\ndef hello\n  123\nend"
    window.buffer.content = code_with_multibyte

    # This will fail without proper byte-to-char conversion
    # because "def" starts at byte offset 24 (after "# 日本語コメント\n")
    # but at character offset 10 (after "# 日本語コメント\n" which is 10 chars)
    mode.custom_highlight(window)

    # Verify that we have some highlights
    highlight_on = window.highlight_on
    refute_empty highlight_on, "Should have highlights even with multibyte content"

    # Calculate expected character positions
    # "# 日本語コメント\n" is 10 characters (including newline)
    # "def" should start at character position 10
    comment_line = "# 日本語コメント\n"
    assert_equal 10, comment_line.length, "Comment line should be 10 characters"
    assert_equal 24, comment_line.bytesize, "Comment line should be 24 bytes"

    # The key test: highlights should use character offsets, not byte offsets
    # If using byte offsets incorrectly, highlight would be at position 24
    # If using character offsets correctly, highlight should be at position 10
    positions = highlight_on.keys.sort

    # With proper conversion, positions should be in the character offset range 0-32
    # (32 = length of entire string)
    max_char_position = code_with_multibyte.length
    assert_equal 32, max_char_position, "Total length should be 32 characters"

    # All highlight positions should be valid character positions (not byte positions)
    positions.each do |pos|
      assert pos >= 0 && pos <= max_char_position,
             "Position #{pos} should be within character range 0-#{max_char_position}"
    end
  end

  private

  def create_test_mode(language)
    klass = Class.new(Textbringer::Mode) do
      extend Textbringer::TreeSitterAdapter::ClassMethods
      use_tree_sitter language
    end
    klass.new
  end
end
