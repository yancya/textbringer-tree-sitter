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

  # --- キャッシュ関連テスト ---

  # 同じ内容で2回呼ぶと、2回目はキャッシュが効く
  def test_get_cached_tree_returns_tree_when_content_unchanged
    mode = create_test_mode(:ruby)
    buffer = Textbringer::MockBuffer.new
    buffer_text = "def hello; end"
    fake_tree = Object.new

    mode.send(:cache_tree, buffer, fake_tree, buffer_text)
    result = mode.send(:get_cached_tree, buffer, buffer_text)

    assert_same fake_tree, result
  end

  # 内容が変わったらキャッシュ無効
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

  # 言語が変わったらキャッシュ無効
  def test_get_cached_tree_returns_nil_when_language_changed
    mode_ruby = create_test_mode(:ruby)
    mode_hcl = create_test_mode(:hcl)
    buffer = Textbringer::MockBuffer.new
    buffer_text = "some code"
    fake_tree = Object.new

    # ruby mode でキャッシュ → hcl mode で取得（言語不一致）
    # 同じ @tree_cache を共有するために instance variable を移植
    mode_ruby.send(:cache_tree, buffer, fake_tree, buffer_text)
    mode_hcl.instance_variable_set(:@tree_cache, mode_ruby.instance_variable_get(:@tree_cache))

    result = mode_hcl.send(:get_cached_tree, buffer, buffer_text)
    assert_nil result
  end

  # キャッシュが10を超えたら最古のエントリが evict される
  def test_cache_tree_evicts_oldest_entry_when_exceeding_limit
    mode = create_test_mode(:ruby)

    buffers = 11.times.map { Textbringer::MockBuffer.new }
    buffers.each_with_index do |buf, i|
      text = "code #{i}"
      mode.send(:cache_tree, buf, Object.new, text)
    end

    cache = mode.instance_variable_get(:@tree_cache)
    assert_equal 10, cache.size

    # 最初に入れた buffer[0] は evict されている
    first_buffer_id = buffers[0].object_id
    refute cache.key?(first_buffer_id), "最古のエントリが evict されていない"

    # 最後に入れた buffer[10] は残っている
    last_buffer_id = buffers[10].object_id
    assert cache.key?(last_buffer_id), "最新のエントリが消えている"
  end

  # アクセスしたエントリは LRU 順が更新されて evict されない
  def test_get_cached_tree_refreshes_lru_order
    mode = create_test_mode(:ruby)

    # 11 個のバッファを用意
    buffers = 11.times.map { Textbringer::MockBuffer.new }
    texts = 11.times.map { |i| "code #{i}" }

    # まず 10 個キャッシュ
    10.times do |i|
      mode.send(:cache_tree, buffers[i], Object.new, texts[i])
    end

    # buffer[0] にアクセスして LRU 順を更新
    result = mode.send(:get_cached_tree, buffers[0], texts[0])
    refute_nil result, "buffer[0] のキャッシュが見つからない"

    # 11 個目を追加（eviction 発生）
    mode.send(:cache_tree, buffers[10], Object.new, texts[10])

    cache = mode.instance_variable_get(:@tree_cache)
    assert_equal 10, cache.size

    # buffer[0] はアクセス済みなので evict されない
    assert cache.key?(buffers[0].object_id), "アクセス済みの buffer[0] が evict された"
    # buffer[1] が最古になって evict される
    refute cache.key?(buffers[1].object_id), "buffer[1] が evict されていない"
  end

  # --- visit_node テスト ---

  def test_visit_node_yields_only_leaf_nodes
    mode = create_test_mode(:ruby)

    # mock ノードツリー:
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

    # リーフノードのみが yield される
    assert_equal 2, yielded.size
    assert_equal ["leaf_a", 5, 10], yielded[0]
    assert_equal ["leaf_b", 15, 20], yielded[1]

    # コンテナノード (root, container) は yield されない
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

  private

  # visit_node テスト用の mock ノード
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
end
