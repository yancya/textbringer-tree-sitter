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

  # byte_offset_to_char_offset 単体テスト
  def test_byte_offset_to_char_offset_with_ascii
    mode = create_test_mode(:ruby)
    text = "def hello"

    # ASCII のみ: byte offset == char offset
    assert_equal 0, mode.send(:byte_offset_to_char_offset, text, 0)
    assert_equal 3, mode.send(:byte_offset_to_char_offset, text, 3)
    assert_equal 9, mode.send(:byte_offset_to_char_offset, text, 9)
  end

  def test_byte_offset_to_char_offset_with_multibyte
    mode = create_test_mode(:ruby)
    # "# 日本語コメント\n" は 10 文字 / 24 bytes
    text = "# 日本語コメント\ndef hello"

    # offset 0 → char 0
    assert_equal 0, mode.send(:byte_offset_to_char_offset, text, 0)
    # "# " は 2 bytes / 2 chars
    assert_equal 2, mode.send(:byte_offset_to_char_offset, text, 2)
    # "# 日" は 3 chars / 5 bytes
    assert_equal 3, mode.send(:byte_offset_to_char_offset, text, 5)
    # "# 日本語コメント\n" は 10 chars / 24 bytes
    assert_equal 10, mode.send(:byte_offset_to_char_offset, text, 24)
    # "# 日本語コメント\ndef" は 13 chars / 27 bytes
    assert_equal 13, mode.send(:byte_offset_to_char_offset, text, 27)
  end

  def test_byte_offset_to_char_offset_edge_cases
    mode = create_test_mode(:ruby)
    text = "あいう"

    # 負値 → 0
    assert_equal 0, mode.send(:byte_offset_to_char_offset, text, -1)
    # bytesize 超え → string.length
    assert_equal 3, mode.send(:byte_offset_to_char_offset, text, 100)
    # ちょうど bytesize → string.length
    assert_equal 3, mode.send(:byte_offset_to_char_offset, text, text.bytesize)
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
