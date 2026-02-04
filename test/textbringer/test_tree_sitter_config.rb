# frozen_string_literal: true

require "test_helper"
require "textbringer/tree_sitter_config"

class TreeSitterConfigTest < Minitest::Test
  def setup
    Textbringer::Face.clear_all
  end

  def test_platform_detection
    platform = Textbringer::TreeSitterConfig.platform
    assert_includes %w[darwin-arm64 darwin-x64 linux-x64 linux-arm64], platform
  end

  def test_dylib_ext_on_darwin
    original = RbConfig::CONFIG["host_os"]
    begin
      # macOS
      RbConfig::CONFIG["host_os"] = "darwin23"
      assert_equal ".dylib", Textbringer::TreeSitterConfig.dylib_ext
    ensure
      RbConfig::CONFIG["host_os"] = original
    end
  end

  def test_dylib_ext_on_linux
    original = RbConfig::CONFIG["host_os"]
    begin
      RbConfig::CONFIG["host_os"] = "linux-gnu"
      assert_equal ".so", Textbringer::TreeSitterConfig.dylib_ext
    ensure
      RbConfig::CONFIG["host_os"] = original
    end
  end

  def test_parser_dir
    parser_dir = Textbringer::TreeSitterConfig.parser_dir
    platform = Textbringer::TreeSitterConfig.platform
    assert parser_dir.include?("parsers")
    assert parser_dir.end_with?(platform), "Expected #{parser_dir} to end with #{platform}"
  end

  def test_define_default_faces
    Textbringer::TreeSitterConfig.define_default_faces

    assert Textbringer::Face[:comment]
    assert Textbringer::Face[:string]
    assert Textbringer::Face[:keyword]
    assert Textbringer::Face[:number]
    assert Textbringer::Face[:constant]
    assert Textbringer::Face[:function_name]
    assert Textbringer::Face[:type]
    assert Textbringer::Face[:variable]
    assert Textbringer::Face[:operator]
    assert Textbringer::Face[:punctuation]
    assert Textbringer::Face[:builtin]
    assert Textbringer::Face[:property]
  end

  def test_define_default_faces_has_correct_attributes
    Textbringer::TreeSitterConfig.define_default_faces

    # 代表的な Face の属性をチェック
    assert_equal({ foreground: "green" }, Textbringer::Face[:comment].attributes)
    assert_equal({ foreground: "cyan" }, Textbringer::Face[:string].attributes)
    assert_equal({ foreground: "yellow" }, Textbringer::Face[:keyword].attributes)
  end

  def test_parser_path_returns_correct_path
    parser_path = Textbringer::TreeSitterConfig.parser_path(:ruby)
    expected_suffix = "libtree-sitter-ruby#{Textbringer::TreeSitterConfig.dylib_ext}"
    assert parser_path.end_with?(expected_suffix)
  end

  def test_parser_available_returns_false_for_missing_parser
    refute Textbringer::TreeSitterConfig.parser_available?(:nonexistent_language)
  end
end
