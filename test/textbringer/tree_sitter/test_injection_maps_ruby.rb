# frozen_string_literal: true

require "test_helper"
require "textbringer/tree_sitter/injection_maps"

# Minimal duck-typed node double matching the tree-sitter-ruby heredoc shape:
#   heredoc_body
#     heredoc_content
#     heredoc_end   <- carries the plain tag text, e.g. "SQL" (never quoted,
#                       regardless of whether heredoc_beginning was <<~SQL,
#                       <<~'SQL', or <<SQL -- verified against a live parse)
FakeHeredocNode = Struct.new(:type, :start_byte, :end_byte)
FakeHeredocBody = Struct.new(:children) do
  def type
    :heredoc_body
  end

  def child_count
    children.size
  end

  def child(i)
    children[i]
  end
end

class InjectionMapsRubyTest < Minitest::Test
  # No InjectionMaps.clear here: :ruby's heredoc injection is a bundled
  # default (register_default), which clear intentionally leaves alone.

  def entry
    Textbringer::TreeSitter::InjectionMaps.for(:ruby).find { |e| e[:node_type] == :heredoc_body }
  end

  def host_node_and_source(tag_text)
    prefix = "x" * 100
    source = prefix + tag_text
    node = FakeHeredocBody.new([
      FakeHeredocNode.new(:heredoc_content, 0, prefix.bytesize),
      FakeHeredocNode.new(:heredoc_end, prefix.bytesize, source.bytesize)
    ])
    [node, source]
  end

  def resolve(tag_text)
    node, source = host_node_and_source(tag_text)
    entry[:language].call(node, source)
  end

  def test_registers_ruby_heredoc_injection
    refute_nil Textbringer::TreeSitter::InjectionMaps.for(:ruby)
    assert_equal :heredoc_body, entry[:node_type]
    assert_equal :heredoc_content, entry[:content]
  end

  def test_resolves_sql_tag
    assert_equal :sql, resolve("SQL")
  end

  def test_resolves_html_tag
    assert_equal :html, resolve("HTML")
  end

  def test_resolves_json_tag
    assert_equal :json, resolve("JSON")
  end

  def test_resolves_lowercase_tag
    assert_equal :sql, resolve("sql")
  end

  def test_resolves_unrecognized_tags_too
    # No availability check here: an unrecognized tag like EOS still
    # resolves to a symbol. Whether it actually highlights depends on
    # whether a parser for that language is installed -- that check
    # already happens in the engine's get_injected_parser (see S1/#78),
    # so this map doesn't need to duplicate it.
    assert_equal :eos, resolve("EOS")
  end

  def test_missing_heredoc_end_child_returns_nil
    body = FakeHeredocBody.new([FakeHeredocNode.new(:heredoc_content, 0, 5)])
    assert_nil entry[:language].call(body, "x" * 200)
  end
end
