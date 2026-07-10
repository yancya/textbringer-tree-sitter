# frozen_string_literal: true

require_relative "test_helper"
require "textbringer/tree_sitter_adapter"
require "textbringer/tree_sitter/injection_maps"

# Minimal duck-typed Tree-sitter node double: no real parser needed to
# exercise the injection engine's tree-walking and offset math.
class FakeNode
  attr_reader :type, :start_byte, :end_byte, :children

  def initialize(type, start_byte, end_byte, children = [])
    @type = type
    @start_byte = start_byte
    @end_byte = end_byte
    @children = children
  end

  def child_count
    children.size
  end

  def child(i)
    children[i]
  end
end

FakeTree = Struct.new(:root_node)

class FakeParser
  attr_reader :call_count

  def initialize(tree)
    @tree = tree
    @call_count = 0
  end

  def parse_string(_old_tree, _text)
    @call_count += 1
    @tree
  end
end

class TestTreeSitterInjection < Minitest::Test
  def setup
    Textbringer::Face.clear_all
    Textbringer::CONFIG.clear
    Textbringer::TreeSitter::InjectionMaps.clear
    Textbringer::TreeSitter::NodeMaps.clear_custom_maps

    Textbringer::TreeSitterConfig.define_default_faces

    @test_mode_class = Class.new(Textbringer::Mode)
    @test_mode_class.extend(Textbringer::TreeSitterAdapter::ClassMethods)
    @test_mode_class.use_tree_sitter(:ruby)

    @mode = @test_mode_class.new
    @buffer = Textbringer::MockBuffer.new
    @buffer.mode = @mode
  end

  def content_node(source_offset, text)
    FakeNode.new(:heredoc_content, source_offset, source_offset + text.bytesize)
  end

  def host_root(content)
    FakeNode.new(:program, 0, 100, [
      FakeNode.new(:heredoc_body, content.start_byte, content.end_byte, [content])
    ])
  end

  def ctx_for(source)
    Textbringer::HighlightContext.new(
      buffer: @buffer,
      highlight_start: 0,
      highlight_end: source.bytesize,
      highlight_on: {},
      highlight_off: {}
    )
  end

  def sql_injection_map(language: :sql)
    [{ node_type: :heredoc_body, content: :heredoc_content, language: language }]
  end

  def test_injects_and_highlights_content_with_offset
    Textbringer::TreeSitter::InjectionMaps.register(:ruby, sql_injection_map)
    Textbringer::TreeSitter::NodeMaps.register(:sql, { select_kw: :keyword })

    inner_text = "select_kw"
    offset = 10
    content = content_node(offset, inner_text)
    root = host_root(content)

    inner_root = FakeNode.new(:select_kw, 0, inner_text.bytesize)
    fake_tree = FakeTree.new(inner_root)
    @mode.define_singleton_method(:get_injected_parser) { |_lang| FakeParser.new(fake_tree) }

    source = " " * 100
    ctx = ctx_for(source)
    @mode.send(:highlight_injections, ctx, root, source, 0)

    assert_equal Textbringer::Face[:keyword], ctx.highlight_on[offset]
    assert_equal true, ctx.highlight_off[offset + inner_text.bytesize]
  end

  def test_offset_accounts_for_base_pos
    Textbringer::TreeSitter::InjectionMaps.register(:ruby, sql_injection_map)
    Textbringer::TreeSitter::NodeMaps.register(:sql, { select_kw: :keyword })

    inner_text = "select_kw"
    content = content_node(10, inner_text)
    root = host_root(content)
    inner_root = FakeNode.new(:select_kw, 0, inner_text.bytesize)
    fake_tree = FakeTree.new(inner_root)
    @mode.define_singleton_method(:get_injected_parser) { |_lang| FakeParser.new(fake_tree) }

    source = " " * 100
    ctx = ctx_for(source)
    base_pos = 1000
    @mode.send(:highlight_injections, ctx, root, source, base_pos)

    assert_equal Textbringer::Face[:keyword], ctx.highlight_on[base_pos + 10]
  end

  def test_resolves_language_via_proc
    resolver = ->(_node, _source) { :sql }
    Textbringer::TreeSitter::InjectionMaps.register(:ruby, sql_injection_map(language: resolver))
    Textbringer::TreeSitter::NodeMaps.register(:sql, { select_kw: :keyword })

    inner_text = "select_kw"
    content = content_node(5, inner_text)
    root = host_root(content)
    inner_root = FakeNode.new(:select_kw, 0, inner_text.bytesize)
    fake_tree = FakeTree.new(inner_root)
    @mode.define_singleton_method(:get_injected_parser) { |lang| lang == :sql ? FakeParser.new(fake_tree) : nil }

    source = " " * 100
    ctx = ctx_for(source)
    @mode.send(:highlight_injections, ctx, root, source, 0)

    assert_equal Textbringer::Face[:keyword], ctx.highlight_on[5]
  end

  def test_skips_silently_when_no_injection_map_registered
    content = content_node(5, "select_kw")
    root = host_root(content)

    source = " " * 100
    ctx = ctx_for(source)
    @mode.send(:highlight_injections, ctx, root, source, 0)

    assert_empty ctx.highlight_on
  end

  def test_skips_silently_when_injected_parser_unavailable
    Textbringer::TreeSitter::InjectionMaps.register(:ruby, sql_injection_map)
    content = content_node(5, "select_kw")
    root = host_root(content)
    @mode.define_singleton_method(:get_injected_parser) { |_lang| nil }

    source = " " * 100
    ctx = ctx_for(source)
    @mode.send(:highlight_injections, ctx, root, source, 0)

    assert_empty ctx.highlight_on
  end

  def test_skips_silently_when_content_node_missing
    Textbringer::TreeSitter::InjectionMaps.register(:ruby, sql_injection_map)
    # heredoc_body with no matching :heredoc_content child
    root = FakeNode.new(:program, 0, 100, [
      FakeNode.new(:heredoc_body, 10, 20, [FakeNode.new(:heredoc_end, 18, 20)])
    ])
    @mode.define_singleton_method(:get_injected_parser) { |_lang| raise "should not be called" }

    source = " " * 100
    ctx = ctx_for(source)
    @mode.send(:highlight_injections, ctx, root, source, 0)

    assert_empty ctx.highlight_on
  end

  def test_disabled_via_config_flag
    Textbringer::CONFIG[:tree_sitter_injection] = false
    Textbringer::TreeSitter::InjectionMaps.register(:ruby, sql_injection_map)
    Textbringer::TreeSitter::NodeMaps.register(:sql, { select_kw: :keyword })

    inner_text = "select_kw"
    content = content_node(5, inner_text)
    root = host_root(content)
    inner_root = FakeNode.new(:select_kw, 0, inner_text.bytesize)
    fake_tree = FakeTree.new(inner_root)
    @mode.define_singleton_method(:get_injected_parser) { |_lang| FakeParser.new(fake_tree) }

    source = " " * 100
    ctx = ctx_for(source)
    @mode.send(:highlight_injections, ctx, root, source, 0)

    assert_empty ctx.highlight_on
  end

  def test_depth_limit_does_not_recurse_into_injected_tree
    # Register an injection map for :sql too (as if SQL could embed something else).
    # The engine must not attempt to apply it to the already-injected tree (depth 1).
    Textbringer::TreeSitter::InjectionMaps.register(:ruby, sql_injection_map)
    Textbringer::TreeSitter::InjectionMaps.register(:sql, [{ node_type: :select_kw, content: :inner, language: :json }])
    Textbringer::TreeSitter::NodeMaps.register(:sql, { select_kw: :keyword })

    inner_text = "select_kw"
    content = content_node(5, inner_text)
    root = host_root(content)
    inner_root = FakeNode.new(:select_kw, 0, inner_text.bytesize)
    fake_tree = FakeTree.new(inner_root)

    calls = []
    @mode.define_singleton_method(:get_injected_parser) { |lang|
      calls << lang
      lang == :sql ? FakeParser.new(fake_tree) : (raise "should not recurse into #{lang}")
    }

    source = " " * 100
    ctx = ctx_for(source)
    @mode.send(:highlight_injections, ctx, root, source, 0)

    assert_equal [:sql], calls
  end

  def test_byte_offsets_correct_with_multibyte_prefix
    Textbringer::TreeSitter::InjectionMaps.register(:ruby, sql_injection_map)
    Textbringer::TreeSitter::NodeMaps.register(:sql, { select_kw: :keyword })

    # "あ" is 3 bytes in UTF-8; the injected content starts right after it.
    prefix = "query = # あ\n<<~SQL\n"
    inner_text = "select_kw"
    offset = prefix.bytesize
    content = content_node(offset, inner_text)
    root = host_root(content)

    inner_root = FakeNode.new(:select_kw, 0, inner_text.bytesize)
    fake_tree = FakeTree.new(inner_root)
    @mode.define_singleton_method(:get_injected_parser) { |_lang| FakeParser.new(fake_tree) }

    source = prefix + inner_text + "\nSQL\n"
    ctx = ctx_for(source)
    @mode.send(:highlight_injections, ctx, root, source, 0)

    assert_equal Textbringer::Face[:keyword], ctx.highlight_on[offset]
    assert_equal true, ctx.highlight_off[offset + inner_text.bytesize]
  end

  def test_nested_same_type_host_nodes_both_inject_last_write_wins
    # walk_for_injections is a plain top-down walk with no skip-content
    # behavior: nesting two hosts of the same node_type (unusual, but not
    # prevented) makes both fire. The outer is highlighted first, then the
    # walk descends and the inner (narrower) overwrites it on the shared
    # range, since ctx.highlight is last-write-wins. This documents that
    # behavior rather than crashing or silently dropping one.
    Textbringer::TreeSitter::InjectionMaps.register(:ruby, sql_injection_map)
    Textbringer::TreeSitter::NodeMaps.register(:sql, { select_kw: :keyword, from_kw: :type })

    outer_content = content_node(0, "outer_select_kw")
    inner_content = content_node(6, "select_kw")
    inner_host = FakeNode.new(:heredoc_body, inner_content.start_byte, inner_content.end_byte, [inner_content])
    outer_host = FakeNode.new(:heredoc_body, outer_content.start_byte, outer_content.end_byte,
                               [outer_content, inner_host])
    root = FakeNode.new(:program, 0, 100, [outer_host])

    outer_tree = FakeTree.new(FakeNode.new(:from_kw, 0, "outer_select_kw".bytesize))
    inner_tree = FakeTree.new(FakeNode.new(:select_kw, 0, "select_kw".bytesize))
    trees = [outer_tree, inner_tree]
    @mode.define_singleton_method(:get_injected_parser) { |_lang| FakeParser.new(trees.shift) }

    source = " " * 100
    ctx = ctx_for(source)
    @mode.send(:highlight_injections, ctx, root, source, 0)

    # Both hosts fired (outer's :from_kw face, then inner's :select_kw face
    # overwrote the overlapping start offset since it's processed second).
    assert_equal Textbringer::Face[:keyword], ctx.highlight_on[inner_content.start_byte]
  end

  def test_self_injection_when_content_type_equals_node_type
    # ERB's "content" nodes (plain HTML/text between directives) ARE the
    # leaf to inject, not a wrapper around one -- entry[:content] equal to
    # entry[:node_type] means "inject this node itself".
    Textbringer::TreeSitter::InjectionMaps.register(:embedded_template,
      [{ node_type: :content, content: :content, language: :html }])
    Textbringer::TreeSitter::NodeMaps.register(:html, { tag_name: :keyword })

    erb_mode_class = Class.new(Textbringer::Mode)
    erb_mode_class.extend(Textbringer::TreeSitterAdapter::ClassMethods)
    erb_mode_class.use_tree_sitter(:embedded_template)
    erb_mode = erb_mode_class.new
    erb_buffer = Textbringer::MockBuffer.new
    erb_buffer.mode = erb_mode

    host = FakeNode.new(:content, 5, 15)
    root = FakeNode.new(:template, 0, 100, [host])

    inner_root = FakeNode.new(:tag_name, 0, 10)
    fake_tree = FakeTree.new(inner_root)
    erb_mode.define_singleton_method(:get_injected_parser) { |_lang| FakeParser.new(fake_tree) }

    source = " " * 100
    ctx = Textbringer::HighlightContext.new(
      buffer: erb_buffer,
      highlight_start: 0,
      highlight_end: source.bytesize,
      highlight_on: {},
      highlight_off: {}
    )
    erb_mode.send(:highlight_injections, ctx, root, source, 0)

    assert_equal Textbringer::Face[:keyword], ctx.highlight_on[5]
    assert_equal true, ctx.highlight_off[15]
  end

  def test_unchanged_injected_content_is_not_reparsed
    Textbringer::TreeSitter::InjectionMaps.register(:ruby, sql_injection_map)
    Textbringer::TreeSitter::NodeMaps.register(:sql, { select_kw: :keyword })

    inner_text = "select_kw"
    content = content_node(10, inner_text)
    root = host_root(content)
    fake_parser = FakeParser.new(FakeTree.new(FakeNode.new(:select_kw, 0, inner_text.bytesize)))
    @mode.define_singleton_method(:get_injected_parser) { |_lang| fake_parser }

    source = " " * 100
    @mode.send(:highlight_injections, ctx_for(source), root, source, 0)
    @mode.send(:highlight_injections, ctx_for(source), root, source, 0)

    assert_equal 1, fake_parser.call_count
  end

  def test_changed_injected_content_is_reparsed
    Textbringer::TreeSitter::InjectionMaps.register(:ruby, sql_injection_map)
    Textbringer::TreeSitter::NodeMaps.register(:sql, { select_kw: :keyword })

    fake_parser = FakeParser.new(FakeTree.new(FakeNode.new(:select_kw, 0, 9)))
    @mode.define_singleton_method(:get_injected_parser) { |_lang| fake_parser }

    prefix = " " * 10
    content1 = content_node(10, "select_kw")
    source1 = prefix + "select_kw" + (" " * 81)
    @mode.send(:highlight_injections, ctx_for(source1), host_root(content1), source1, 0)

    content2 = content_node(10, "update_kw")
    source2 = prefix + "update_kw" + (" " * 81)
    @mode.send(:highlight_injections, ctx_for(source2), host_root(content2), source2, 0)

    assert_equal 2, fake_parser.call_count
  end

  def test_injected_tree_cache_is_bounded
    Textbringer::TreeSitter::InjectionMaps.register(:ruby, sql_injection_map)
    Textbringer::TreeSitter::NodeMaps.register(:sql, { select_kw: :keyword })

    fake_parser = FakeParser.new(FakeTree.new(FakeNode.new(:select_kw, 0, 3)))
    @mode.define_singleton_method(:get_injected_parser) { |_lang| fake_parser }

    source = " " * 200
    20.times do |i|
      text = "kw#{i}"
      content = content_node(10, text)
      @mode.send(:highlight_injections, ctx_for(source), host_root(content), source, 0)
    end

    cache = @mode.instance_variable_get(:@injected_tree_cache)
    refute_nil cache
    assert_operator cache.size, :<=, 10
  end
end
