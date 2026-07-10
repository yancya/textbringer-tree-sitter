# frozen_string_literal: true

require "test_helper"
require "textbringer/tree_sitter/injection_maps"

class InjectionMapsTest < Minitest::Test
  def setup
    Textbringer::TreeSitter::InjectionMaps.clear
  end

  def teardown
    Textbringer::TreeSitter::InjectionMaps.clear
  end

  def test_for_returns_nil_when_nothing_registered
    assert_nil Textbringer::TreeSitter::InjectionMaps.for(:custom_lang)
  end

  def test_register_and_for_roundtrip
    entries = [{ node_type: :heredoc_body, content: :heredoc_content, language: :sql }]
    Textbringer::TreeSitter::InjectionMaps.register(:custom_lang, entries)

    assert_equal entries, Textbringer::TreeSitter::InjectionMaps.for(:custom_lang)
  end

  def test_register_normalizes_language_aliases
    entries = [{ node_type: :x, content: :y, language: :html }]
    Textbringer::TreeSitter::InjectionMaps.register(:"c-sharp", entries)

    assert_equal entries, Textbringer::TreeSitter::InjectionMaps.for(:csharp)
    assert_equal entries, Textbringer::TreeSitter::InjectionMaps.for(:"c-sharp")
  end

  def test_for_accepts_proc_language_resolver
    resolver = ->(node, source) { :sql }
    entries = [{ node_type: :heredoc_body, content: :heredoc_content, language: resolver }]
    Textbringer::TreeSitter::InjectionMaps.register(:custom_lang, entries)

    got = Textbringer::TreeSitter::InjectionMaps.for(:custom_lang)
    assert_equal :sql, got.first[:language].call(nil, nil)
  end

  def test_clear_removes_custom_registrations
    Textbringer::TreeSitter::InjectionMaps.register(:custom_lang, [{ node_type: :a, content: :b, language: :sql }])
    Textbringer::TreeSitter::InjectionMaps.clear

    assert_nil Textbringer::TreeSitter::InjectionMaps.for(:custom_lang)
  end

  def test_clear_does_not_remove_bundled_defaults
    Textbringer::TreeSitter::InjectionMaps.clear

    refute_nil Textbringer::TreeSitter::InjectionMaps.for(:ruby)
  end

  def test_custom_registration_is_combined_with_bundled_defaults
    Textbringer::TreeSitter::InjectionMaps.register(:ruby, [{ node_type: :c, content: :d, language: :html }])

    result = Textbringer::TreeSitter::InjectionMaps.for(:ruby)
    assert_includes result.map { |e| e[:node_type] }, :heredoc_body
    assert_includes result.map { |e| e[:node_type] }, :c
  end
end
