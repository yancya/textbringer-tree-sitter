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

  # use_tree_sitter class method
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

  # custom_highlight initialization
  def test_custom_highlight_initializes_highlight_hashes
    mode = create_test_mode(:ruby)
    window = Textbringer::Window.new

    mode.custom_highlight(window)

    assert_kind_of Hash, window.highlight_on
    assert_kind_of Hash, window.highlight_off
  end

  # Early return when colors are disabled
  def test_custom_highlight_returns_early_when_colors_disabled
    Textbringer::CONFIG[:colors] = false

    mode = create_test_mode(:ruby)
    window = Textbringer::Window.new

    # Verify it completes without error
    mode.custom_highlight(window)

    assert_equal({}, window.highlight_on)
  end

  def test_custom_highlight_works_when_colors_enabled
    Textbringer::CONFIG[:colors] = true

    mode = create_test_mode(:ruby)
    window = Textbringer::Window.new

    # Should not raise even without a parser
    mode.custom_highlight(window)

    # No highlights since there is no parser
    assert_kind_of Hash, window.highlight_on
  end

  # Early return when syntax_highlight is disabled
  def test_custom_highlight_returns_early_when_syntax_highlight_disabled
    Textbringer::CONFIG[:colors] = true
    Textbringer::CONFIG[:syntax_highlight] = false

    mode = create_test_mode(:ruby)
    window = Textbringer::Window.new

    mode.custom_highlight(window)

    assert_equal({}, window.highlight_on)
  end

  # node_type_to_face mapping
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

  # Level control
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
    # Defaults to level 3 when not configured
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

    # Only comment and string are enabled at level 1
    assert_equal :comment, mode.send(:node_type_to_face, :comment)
    assert_equal :string, mode.send(:node_type_to_face, :string_content)
    # keyword requires level 2+, so nil here
    assert_nil mode.send(:node_type_to_face, :def)
  end

  # Custom enabled_features configuration
  def test_enabled_features_custom
    Textbringer::CONFIG[:tree_sitter_enabled_features] = %i[comment keyword]

    mode = create_test_mode(:ruby)
    faces = mode.send(:enabled_faces)

    assert_includes faces, :comment
    assert_includes faces, :keyword
    refute_includes faces, :string
    refute_includes faces, :function_name
  end

  # Verify HCL Rouge issue is resolved
  def test_hcl_for_in_recognized_as_keyword
    mode = create_test_mode(:hcl)

    # for, in were classified as Name.Other in Rouge; now recognized as keywords
    assert_equal :keyword, mode.send(:node_type_to_face, :for)
    assert_equal :keyword, mode.send(:node_type_to_face, :in)
  end

  def test_hcl_function_call_recognized
    mode = create_test_mode(:hcl)

    # function_call was not recognized by Rouge
    assert_equal :function_name, mode.send(:node_type_to_face, :function_call)
  end

  # Verify Window monkey-patch
  def test_window_has_highlight_method
    assert Textbringer::Window.method_defined?(:highlight)
  end

  # --- Cache-related tests ---

  # Calling twice with the same content should use the cache on the second call
  def test_get_cached_tree_returns_tree_when_content_unchanged
    mode = create_test_mode(:ruby)
    buffer = Textbringer::MockBuffer.new
    buffer_text = "def hello; end"
    fake_tree = Object.new

    mode.send(:cache_tree, buffer, fake_tree, buffer_text)
    result = mode.send(:get_cached_tree, buffer, buffer_text)

    assert_same fake_tree, result
  end

  # Cache is invalidated when content changes
  def test_get_cached_tree_returns_nil_when_content_changed
    mode = create_test_mode(:ruby)
    buffer = Textbringer::MockBuffer.new
    buffer_text_v1 = "def hello; end"
    buffer_text_v2 = "def world; end"
    fake_tree = Object.new

    mode.send(:cache_tree, buffer, fake_tree, buffer_text_v1)
    result = mode.send(:get_cached_tree, buffer, buffer_text_v2)

    assert_nil result
  end

  # Cache is invalidated when language changes
  def test_get_cached_tree_returns_nil_when_language_changed
    mode_ruby = create_test_mode(:ruby)
    mode_hcl = create_test_mode(:hcl)
    buffer = Textbringer::MockBuffer.new
    buffer_text = "some code"
    fake_tree = Object.new

    # Cache with ruby mode, then retrieve with hcl mode (language mismatch)
    # Transplant the instance variable to share the same @tree_cache
    mode_ruby.send(:cache_tree, buffer, fake_tree, buffer_text)
    mode_hcl.instance_variable_set(:@tree_cache, mode_ruby.instance_variable_get(:@tree_cache))

    result = mode_hcl.send(:get_cached_tree, buffer, buffer_text)
    assert_nil result
  end

  # The oldest entry is evicted when the cache exceeds 10
  def test_cache_tree_evicts_oldest_entry_when_exceeding_limit
    mode = create_test_mode(:ruby)

    buffers = 11.times.map { Textbringer::MockBuffer.new }
    buffers.each_with_index do |buf, i|
      text = "code #{i}"
      mode.send(:cache_tree, buf, Object.new, text)
    end

    cache = mode.instance_variable_get(:@tree_cache)
    assert_equal 10, cache.size

    # The first inserted buffer[0] should have been evicted
    first_buffer_id = buffers[0].object_id
    refute cache.key?(first_buffer_id), "最古のエントリが evict されていない"

    # The last inserted buffer[10] should still remain
    last_buffer_id = buffers[10].object_id
    assert cache.key?(last_buffer_id), "最新のエントリが消えている"
  end

  # Accessed entries have their LRU order refreshed and are not evicted
  def test_get_cached_tree_refreshes_lru_order
    mode = create_test_mode(:ruby)

    # Prepare 11 buffers
    buffers = 11.times.map { Textbringer::MockBuffer.new }
    texts = 11.times.map { |i| "code #{i}" }

    # Cache the first 10
    10.times do |i|
      mode.send(:cache_tree, buffers[i], Object.new, texts[i])
    end

    # Access buffer[0] to refresh its LRU order
    result = mode.send(:get_cached_tree, buffers[0], texts[0])
    refute_nil result, "Cache for buffer[0] not found"

    # Add the 11th entry (triggers eviction)
    mode.send(:cache_tree, buffers[10], Object.new, texts[10])

    cache = mode.instance_variable_get(:@tree_cache)
    assert_equal 10, cache.size

    # buffer[0] was accessed, so it should not be evicted
    assert cache.key?(buffers[0].object_id), "Accessed buffer[0] was evicted"
    # buffer[1] became the oldest and should be evicted
    refute cache.key?(buffers[1].object_id), "buffer[1] was not evicted"
  end

  # --- visit_node tests ---

  # Verify that highlight_on/off keys use byte offsets for buffers containing multibyte characters
  def test_custom_highlight_uses_byte_offsets_for_multibyte
    skip "Ruby parser not installed" unless parser_available?(:ruby)
    skip "tree_sitter gem not available" unless tree_sitter_available?

    Textbringer::Face.define(:comment, foreground: "blue")
    Textbringer::CONFIG[:tree_sitter_highlight_level] = 1

    mode = create_test_mode(:ruby)
    buffer = Textbringer::MockBuffer.new
    # "# 日本語\n" is 13 bytes (# + space + 日本語 = 2 + 9 + 1 = 12... let's count)
    # "# " = 2 bytes, "日" = 3 bytes, "本" = 3 bytes, "語" = 3 bytes, "\n" = 1 byte -> total 12 bytes
    # 6 characters ("# 日本語\n")
    buffer.content = "# 日本語\n"
    buffer.mode = mode
    window = Textbringer::Window.new(buffer)

    mode.custom_highlight(window)

    highlight_on = window.instance_variable_get(:@highlight_on)
    highlight_off = window.instance_variable_get(:@highlight_off)

    # There should be highlights for the comment
    refute_empty highlight_on, "Expected highlights for multibyte comment"

    # Keys should be byte offsets (not character offsets)
    # The comment starts at position 0
    assert highlight_on.key?(0), "Expected highlight_on at byte offset 0"

    # The comment end position is byte offset 11 (excluding newline) or 12 (including newline)
    # Depends on tree-sitter parse result, but should not be character offset (5)
    end_positions = highlight_off.keys
    # Byte offsets would be 11 or 12; character offsets would be 5 or 6
    # Verify byte offsets are used
    assert end_positions.any? { |pos| pos > 6 },
      "Expected byte offsets (>6) but got char offsets: #{end_positions.inspect}"
  end

  def test_visit_node_yields_only_leaf_nodes
    mode = create_test_mode(:ruby)

    # Mock node tree:
    #   root (child_count=2)
    #     ├── container (child_count=1)
    #     │   └── leaf_a (child_count=0)
    #     └── leaf_b (child_count=0)
    leaf_a = MockNode.new("leaf_a", 5, 10, [])
    leaf_b = MockNode.new("leaf_b", 15, 20, [])
    container = MockNode.new("container", 0, 12, [leaf_a])
    root = MockNode.new("root", 0, 20, [container, leaf_b])

    yielded = []
    mode.send(:visit_node, root) do |node, start_byte, end_byte|
      yielded << [node.type, start_byte, end_byte]
    end

    # Only leaf nodes should be yielded
    assert_equal 2, yielded.size
    assert_equal ["leaf_a", 5, 10], yielded[0]
    assert_equal ["leaf_b", 15, 20], yielded[1]

    # Container nodes (root, container) should not be yielded
    types = yielded.map(&:first)
    refute_includes types, "root"
    refute_includes types, "container"
  end

  def test_visit_node_handles_single_leaf
    mode = create_test_mode(:ruby)

    leaf = MockNode.new("keyword", 0, 3, [])

    yielded = []
    mode.send(:visit_node, leaf) do |node, start_byte, end_byte|
      yielded << [node.type, start_byte, end_byte]
    end

    assert_equal 1, yielded.size
    assert_equal ["keyword", 0, 3], yielded[0]
  end

  def test_visit_node_yields_mapped_non_leaf_nodes
    mode = create_test_mode(:ruby)

    # Assuming container is mapped in the node_map
    node_map = { container: :function_name }

    leaf_a = MockNode.new("leaf_a", 5, 10, [])
    leaf_b = MockNode.new("leaf_b", 15, 20, [])
    container = MockNode.new("container", 0, 12, [leaf_a])
    root = MockNode.new("root", 0, 20, [container, leaf_b])

    yielded = []
    mode.send(:visit_node, root, node_map) do |node, start_byte, end_byte|
      yielded << [node.type, start_byte, end_byte]
    end

    types = yielded.map(&:first)
    # container is mapped, so it should be yielded
    assert_includes types, "container"
    # Leaf nodes should still be yielded
    assert_includes types, "leaf_a"
    assert_includes types, "leaf_b"
    # root is not mapped, so it should not be yielded
    refute_includes types, "root"
  end

  # When a parent node is in the node_map and a child maps to the same face,
  # the child is not yielded (to avoid splitting the parent's highlight range)
  def test_visit_node_skips_children_covered_by_same_face
    mode = create_test_mode(:ruby)

    # Pattern: double_quote_scalar (string) -> escape_sequence (string)
    node_map = { parent_string: :string, child_esc: :string }

    child_esc = MockNode.new("child_esc", 10, 15, [])
    parent_string = MockNode.new("parent_string", 0, 20, [child_esc])

    yielded = []
    mode.send(:visit_node, parent_string, node_map) do |node, start_byte, end_byte|
      yielded << [node.type, start_byte, end_byte]
    end

    types = yielded.map(&:first)
    # Parent is mapped, so it should be yielded
    assert_includes types, "parent_string"
    # Child has the same face, so it is not yielded (covered by the parent's range)
    refute_includes types, "child_esc"
  end

  # When parent and child have different faces, the child is also yielded
  def test_visit_node_yields_children_with_different_face
    mode = create_test_mode(:ruby)

    node_map = { parent_mod: :keyword, child_const: :constant }

    child_const = MockNode.new("child_const", 7, 19, [])
    parent_mod = MockNode.new("parent_mod", 0, 30, [child_const])

    yielded = []
    mode.send(:visit_node, parent_mod, node_map) do |node, start_byte, end_byte|
      yielded << [node.type, start_byte, end_byte]
    end

    types = yielded.map(&:first)
    # Both parent and child are yielded (different faces)
    assert_includes types, "parent_mod"
    assert_includes types, "child_const"
  end

  # Unmapped leaf nodes are yielded even inside a covered parent
  # (harmless because node_type_to_face returns nil in the block)
  def test_visit_node_yields_unmapped_leaves_inside_covered_parent
    mode = create_test_mode(:ruby)

    node_map = { parent_string: :string }

    unmapped_leaf = MockNode.new("quote_char", 0, 1, [])
    parent_string = MockNode.new("parent_string", 0, 20, [unmapped_leaf])

    yielded = []
    mode.send(:visit_node, parent_string, node_map) do |node, start_byte, end_byte|
      yielded << [node.type, start_byte, end_byte]
    end

    types = yielded.map(&:first)
    assert_includes types, "parent_string"
    # Unmapped leaf is yielded (skipped by the block)
    assert_includes types, "quote_char"
  end

  def test_visit_node_without_node_map_yields_only_leaves
    mode = create_test_mode(:ruby)

    leaf_a = MockNode.new("leaf_a", 5, 10, [])
    container = MockNode.new("container", 0, 12, [leaf_a])

    yielded = []
    mode.send(:visit_node, container) do |node, start_byte, end_byte|
      yielded << [node.type, start_byte, end_byte]
    end

    # Without node_map, only leaves are yielded (backward compatible)
    types = yielded.map(&:first)
    assert_includes types, "leaf_a"
    refute_includes types, "container"
  end

  private

  # Mock node for visit_node tests
  MockNode = Struct.new(:type, :start_byte, :end_byte, :children) do
    def child_count
      children.size
    end

    def child(index)
      children[index]
    end
  end

  def create_test_mode(language)
    klass = Class.new(Textbringer::Mode) do
      extend Textbringer::TreeSitterAdapter::ClassMethods
      use_tree_sitter language
    end
    klass.new
  end

  def parser_available?(language)
    Textbringer::TreeSitterConfig.parser_available?(language)
  end

  def tree_sitter_available?
    require "tree_sitter"
    true
  rescue LoadError
    false
  end
end
