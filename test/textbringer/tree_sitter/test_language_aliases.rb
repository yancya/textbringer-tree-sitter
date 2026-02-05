# frozen_string_literal: true

require "test_helper"
require "textbringer/tree_sitter/language_aliases"

class TestLanguageAliases < Minitest::Test
  include Textbringer::TreeSitter

  def test_normalize_removes_hyphens
    assert_equal "csharp", LanguageAliases.normalize("c-sharp")
  end

  def test_normalize_removes_underscores
    assert_equal "csharp", LanguageAliases.normalize("c_sharp")
  end

  def test_normalize_lowercases
    assert_equal "csharp", LanguageAliases.normalize("CSharp")
    assert_equal "csharp", LanguageAliases.normalize("C-Sharp")
  end

  def test_normalize_handles_symbols
    assert_equal "csharp", LanguageAliases.normalize(:"c-sharp")
    assert_equal "ruby", LanguageAliases.normalize(:ruby)
  end

  def test_normalize_resolves_known_aliases
    assert_equal "csharp", LanguageAliases.normalize("cs")
    assert_equal "javascript", LanguageAliases.normalize("js")
    assert_equal "typescript", LanguageAliases.normalize("ts")
    assert_equal "python", LanguageAliases.normalize("py")
    assert_equal "ruby", LanguageAliases.normalize("rb")
  end

  def test_normalize_handles_unknown_languages
    assert_equal "foobar", LanguageAliases.normalize("foobar")
    assert_equal "foobar", LanguageAliases.normalize("foo-bar")
    assert_equal "foobar", LanguageAliases.normalize("foo_bar")
  end

  def test_to_sym_returns_symbol
    assert_equal :csharp, LanguageAliases.to_sym("c-sharp")
    assert_equal :ruby, LanguageAliases.to_sym(:ruby)
    assert_equal :javascript, LanguageAliases.to_sym("js")
  end

  def test_normalize_is_idempotent
    normalized = LanguageAliases.normalize("c-sharp")
    assert_equal normalized, LanguageAliases.normalize(normalized)
  end
end
