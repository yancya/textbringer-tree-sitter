# frozen_string_literal: true

require_relative "test_helper"

# Load the CLI module
load File.expand_path("../exe/textbringer-tree-sitter", __dir__)

class TestLanguageConfig < Minitest::Test
  include TextbringerTreeSitterCLI

  def setup
    @temp_home = Dir.mktmpdir
    @original_home = ENV["HOME"]
    ENV["HOME"] = @temp_home
  end

  def teardown
    ENV["HOME"] = @original_home
    FileUtils.rm_rf(@temp_home) if @temp_home && File.exist?(@temp_home)
  end

  def test_language_config_faveod
    config = TextbringerTreeSitterCLI::LanguageConfig.new("ruby", { source: :faveod })
    assert config.faveod?
    refute config.github?
    assert_nil config.repo
  end

  def test_language_config_github_minimal
    config = TextbringerTreeSitterCLI::LanguageConfig.new("elixir", {
      repo: "elixir-lang/tree-sitter-elixir"
    })
    refute config.faveod?
    assert config.github?
    assert_equal "elixir-lang/tree-sitter-elixir", config.repo
    assert_equal "main", config.branch
    assert_nil config.commit
    assert_nil config.subdir
  end

  def test_language_config_github_full
    config = TextbringerTreeSitterCLI::LanguageConfig.new("zig", {
      repo: "maxxnino/tree-sitter-zig",
      branch: "master",
      commit: "abc123",
      subdir: "zig",
      build_cmd: "cc -o {output} {src}/parser.c"
    })
    assert_equal "maxxnino/tree-sitter-zig", config.repo
    assert_equal "master", config.branch
    assert_equal "abc123", config.commit
    assert_equal "zig", config.subdir
    assert_equal "cc -o {output} {src}/parser.c", config.build_cmd
  end

  def test_language_config_missing_repo
    error = assert_raises(ArgumentError) do
      TextbringerTreeSitterCLI::LanguageConfig.new("test", {})
    end
    assert_match(/Missing 'repo'/, error.message)
  end

  def test_load_curated_languages
    curated = TextbringerTreeSitterCLI.load_curated_languages

    # Check Faveod parsers
    assert curated.key?("ruby")
    assert curated.key?("python")
    assert curated["ruby"].faveod?

    # Check build-required parsers
    assert curated.key?("hcl")
    assert curated.key?("yaml")
    assert curated["hcl"].github?
    assert_equal "mitchellh/tree-sitter-hcl", curated["hcl"].repo
  end

  def test_load_user_languages_no_file
    user_langs = TextbringerTreeSitterCLI.load_user_languages
    assert_empty user_langs
  end

  def test_load_user_languages_valid
    config_file = TextbringerTreeSitterCLI.user_config_file
    FileUtils.mkdir_p(File.dirname(config_file))

    yaml_content = <<~YAML
      elixir:
        repo: elixir-lang/tree-sitter-elixir
      zig:
        repo: maxxnino/tree-sitter-zig
        branch: master
    YAML

    File.write(config_file, yaml_content)

    user_langs = TextbringerTreeSitterCLI.load_user_languages

    assert_equal 2, user_langs.size
    assert user_langs.key?("elixir")
    assert user_langs.key?("zig")
    assert_equal "elixir-lang/tree-sitter-elixir", user_langs["elixir"].repo
    assert_equal "main", user_langs["elixir"].branch
    assert_equal "maxxnino/tree-sitter-zig", user_langs["zig"].repo
    assert_equal "master", user_langs["zig"].branch
  end

  def test_load_user_languages_malformed
    config_file = TextbringerTreeSitterCLI.user_config_file
    FileUtils.mkdir_p(File.dirname(config_file))

    # Invalid YAML
    File.write(config_file, "invalid: yaml: content: [")

    # Should not raise, just return empty hash and warn
    user_langs = nil
    _out, err = capture_io do
      user_langs = TextbringerTreeSitterCLI.load_user_languages
    end

    assert_empty user_langs
    assert_match(/Warning.*Failed to load user config/, err)
  end

  def test_all_languages_merges_correctly
    # Create user config that overrides ruby
    config_file = TextbringerTreeSitterCLI.user_config_file
    FileUtils.mkdir_p(File.dirname(config_file))

    yaml_content = <<~YAML
      ruby:
        repo: my-fork/tree-sitter-ruby
        branch: experimental
      elixir:
        repo: elixir-lang/tree-sitter-elixir
    YAML

    File.write(config_file, yaml_content)

    all_langs = TextbringerTreeSitterCLI.all_languages

    # User-defined ruby should override curated
    assert all_langs["ruby"].github?
    assert_equal "my-fork/tree-sitter-ruby", all_langs["ruby"].repo
    assert_equal "experimental", all_langs["ruby"].branch

    # User-defined elixir should be present
    assert all_langs.key?("elixir")
    assert_equal "elixir-lang/tree-sitter-elixir", all_langs["elixir"].repo

    # Other curated languages should still be present
    assert all_langs.key?("python")
    assert all_langs.key?("hcl")
  end

  def test_init_config_creates_file
    config_file = TextbringerTreeSitterCLI.user_config_file
    refute File.exist?(config_file)

    out, _err = capture_io do
      TextbringerTreeSitterCLI.init_config
    end

    assert File.exist?(config_file)
    assert_match(/Created:.*languages\.yml/, out)

    content = File.read(config_file)
    assert_match(/Custom Tree-sitter Languages Configuration/, content)
    assert_match(/elixir:/, content)
  end

  def test_init_config_file_exists
    config_file = TextbringerTreeSitterCLI.user_config_file
    FileUtils.mkdir_p(File.dirname(config_file))
    File.write(config_file, "existing: content")

    out, _err = capture_io do
      TextbringerTreeSitterCLI.init_config
    end

    assert_match(/already exists/, out)
    assert_equal "existing: content", File.read(config_file)
  end
end
