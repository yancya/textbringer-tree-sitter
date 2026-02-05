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

  def test_parser_search_paths_includes_user_dir
    paths = Textbringer::TreeSitterConfig.parser_search_paths
    platform = Textbringer::TreeSitterConfig.platform

    # ~/.textbringer/parsers/{platform} が含まれる
    user_path = File.expand_path("~/.textbringer/parsers/#{platform}")
    assert_includes paths, user_path
  end

  def test_parser_search_paths_includes_gem_dir
    paths = Textbringer::TreeSitterConfig.parser_search_paths

    # gem 内の parsers/{platform} が含まれる
    assert paths.any? { |p| p.include?("parsers") && p.include?(Textbringer::TreeSitterConfig.platform) }
  end

  def test_custom_parser_dir_via_config
    Textbringer::CONFIG[:tree_sitter_parser_dir] = "/custom/parser/dir"

    paths = Textbringer::TreeSitterConfig.parser_search_paths
    assert_equal "/custom/parser/dir", paths.first

    Textbringer::CONFIG.delete(:tree_sitter_parser_dir)
  end

  def test_parser_path_finds_in_search_paths
    # 一時ディレクトリに parser を配置してテスト
    Dir.mktmpdir do |tmpdir|
      platform = Textbringer::TreeSitterConfig.platform
      parser_dir = File.join(tmpdir, platform)
      FileUtils.mkdir_p(parser_dir)

      ext = Textbringer::TreeSitterConfig.dylib_ext
      parser_file = File.join(parser_dir, "libtree-sitter-testlang#{ext}")
      FileUtils.touch(parser_file)

      Textbringer::CONFIG[:tree_sitter_parser_dir] = parser_dir

      assert Textbringer::TreeSitterConfig.parser_available?(:testlang)
      assert_equal parser_file, Textbringer::TreeSitterConfig.parser_path(:testlang)

      Textbringer::CONFIG.delete(:tree_sitter_parser_dir)
    end
  end

  # Language alias resolution tests
  def test_parser_path_normalizes_language_aliases
    Dir.mktmpdir do |tmpdir|
      platform = Textbringer::TreeSitterConfig.platform
      parser_dir = File.join(tmpdir, platform)
      FileUtils.mkdir_p(parser_dir)

      ext = Textbringer::TreeSitterConfig.dylib_ext
      # Create a csharp parser (normalized form)
      parser_file = File.join(parser_dir, "libtree-sitter-csharp#{ext}")
      FileUtils.touch(parser_file)

      Textbringer::CONFIG[:tree_sitter_parser_dir] = parser_dir

      # All these should resolve to the same path
      assert_equal parser_file, Textbringer::TreeSitterConfig.parser_path(:csharp)
      assert_equal parser_file, Textbringer::TreeSitterConfig.parser_path(:"c-sharp")
      assert_equal parser_file, Textbringer::TreeSitterConfig.parser_path("c-sharp")
      assert_equal parser_file, Textbringer::TreeSitterConfig.parser_path(:cs)

      Textbringer::CONFIG.delete(:tree_sitter_parser_dir)
    end
  end

  def test_parser_available_normalizes_language_aliases
    Dir.mktmpdir do |tmpdir|
      platform = Textbringer::TreeSitterConfig.platform
      parser_dir = File.join(tmpdir, platform)
      FileUtils.mkdir_p(parser_dir)

      ext = Textbringer::TreeSitterConfig.dylib_ext
      # Create a csharp parser (normalized form)
      parser_file = File.join(parser_dir, "libtree-sitter-csharp#{ext}")
      FileUtils.touch(parser_file)

      Textbringer::CONFIG[:tree_sitter_parser_dir] = parser_dir

      # All these should be recognized as available
      assert Textbringer::TreeSitterConfig.parser_available?(:csharp)
      assert Textbringer::TreeSitterConfig.parser_available?(:"c-sharp")
      assert Textbringer::TreeSitterConfig.parser_available?("c-sharp")
      assert Textbringer::TreeSitterConfig.parser_available?(:cs)

      Textbringer::CONFIG.delete(:tree_sitter_parser_dir)
    end
  end
end
