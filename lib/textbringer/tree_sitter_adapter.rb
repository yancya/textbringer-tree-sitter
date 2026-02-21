# frozen_string_literal: true

require_relative "tree_sitter_config"
require_relative "tree_sitter/node_maps"

module Textbringer
  module TreeSitterAdapter
    # Emacs 風の 4 段階レベル
    HIGHLIGHT_LEVELS = [
      %i[comment string],                    # Level 1: 最小限
      %i[keyword type constant],             # Level 2: 基本
      %i[function_name variable number],     # Level 3: 標準（デフォルト）
      %i[operator punctuation builtin]       # Level 4: 全部
    ].freeze

    module ClassMethods
      def use_tree_sitter(language)
        @tree_sitter_language = language

        # prepend を使って既存の custom_highlight より優先させる
        prepend InstanceMethods

        define_method(:tree_sitter_language) do
          language
        end
      end

      attr_reader :tree_sitter_language
    end

    def self.debug?
      ENV["TEXTBRINGER_TREE_SITTER_DEBUG"] == "1"
    end

    module InstanceMethods
      def custom_highlight(window)
        window.instance_variable_set(:@highlight_on, {})
        window.instance_variable_set(:@highlight_off, {})

        return unless can_highlight?

        parser = get_parser
        return unless parser

        buffer = window.buffer
        # textbringer 本体と同じロジック: base_pos を基準にする
        base_pos = buffer.point_min
        buffer_text = buffer.to_s

        # 増分パース: 内容未変更なら以前の Tree を再利用
        old_tree = get_cached_tree(buffer, buffer_text)
        tree = parser.parse_string(old_tree, buffer_text)
        return unless tree

        # 新しい Tree をキャッシュ
        cache_tree(buffer, tree, buffer_text)

        if TreeSitterAdapter.debug?
          File.open("/tmp/tree_sitter_debug.log", "a") do |f|
            f.puts "[#{Time.now}] custom_highlight"
            f.puts "  base_pos=#{base_pos} buffer.bytesize=#{buffer_text.bytesize}"
            f.puts "  incremental_parse=#{!old_tree.nil?}"
          end
        end

        highlight_on = {}
        highlight_off = {}

        node_map = TreeSitter::NodeMaps.for(tree_sitter_language)
        visit_node(tree.root_node, node_map) do |node, start_byte, end_byte|
          face = node_type_to_face(node.type.to_sym)
          next unless face

          attrs = Face[face]&.attributes
          if attrs
            # Tree-sitter も Textbringer もバイトオフセットを使う
            highlight_on[base_pos + start_byte] = attrs
            highlight_off[base_pos + end_byte] = attrs

            if TreeSitterAdapter.debug? && highlight_on.size <= 5
              File.open("/tmp/tree_sitter_debug.log", "a") do |f|
                f.puts "  #{node.type} pos=#{base_pos + start_byte}-#{base_pos + end_byte} face=#{face}"
              end
            end
          end
        end

        if TreeSitterAdapter.debug?
          File.open("/tmp/tree_sitter_debug.log", "a") do |f|
            f.puts "  total_highlights=#{highlight_on.size}"
          end
        end

        window.instance_variable_set(:@highlight_on, highlight_on)
        window.instance_variable_set(:@highlight_off, highlight_off)
      end

      private

      def get_cached_tree(buffer, buffer_text)
        @tree_cache ||= {}

        buffer_id = buffer.object_id
        cached = @tree_cache[buffer_id]

        if cached && cached[:language] == tree_sitter_language && cached[:content_hash] == buffer_text.hash
          # LRU リフレッシュ: delete して再挿入で末尾に移動
          @tree_cache.delete(buffer_id)
          @tree_cache[buffer_id] = cached
          cached[:tree]
        else
          # 内容が変わっている or キャッシュなし → フルリパース
          @tree_cache.delete(buffer_id)
          nil
        end
      end

      def cache_tree(buffer, tree, buffer_text)
        @tree_cache ||= {}

        buffer_id = buffer.object_id

        # 既存エントリを削除して再挿入（LRU 順更新）
        @tree_cache.delete(buffer_id)
        @tree_cache[buffer_id] = {
          language: tree_sitter_language,
          tree: tree,
          content_hash: buffer_text.hash
        }

        # LRU eviction
        @tree_cache.shift if @tree_cache.size > 10
      end

      def can_highlight?
        # textbringer 本体と同じチェック: @@has_colors を使う
        return false unless Window.class_variable_get(:@@has_colors)
        return false if CONFIG[:syntax_highlight] == false

        true
      end

      def get_parser
        @parser ||= begin
          return nil unless TreeSitterConfig.parser_available?(tree_sitter_language)
          return nil unless defined?(::TreeSitter)

          parser_path = TreeSitterConfig.parser_path(tree_sitter_language)
          # Normalize language name for TreeSitter::Language.load
          normalized = TreeSitter::LanguageAliases.normalize(tree_sitter_language)
          language = ::TreeSitter::Language.load(
            normalized,
            parser_path
          )

          parser = ::TreeSitter::Parser.new
          parser.language = language
          parser
        rescue LoadError, ::TreeSitter::TreeSitterError, ::TreeSitter::LanguageLoadError
          nil
        end
      end

      def visit_node(node, node_map = nil, covered_face: nil, &block)
        my_face = node_map&.[](node.type.to_sym)

        if node.child_count == 0
          # リーフノード: 親と同じ face でカバー済みなら yield しない
          block.call(node, node.start_byte, node.end_byte) unless my_face && my_face == covered_face
        else
          # 非リーフノード: node_map にあり、親と異なる face なら yield
          if my_face && my_face != covered_face
            block.call(node, node.start_byte, node.end_byte)
          end
          # 子へ再帰（このノードの face を伝播）
          child_covered = my_face || covered_face
          node.child_count.times do |i|
            child = node.child(i)
            visit_node(child, node_map, covered_face: child_covered, &block) if child
          end
        end
      end

      def node_type_to_face(node_type)
        node_map = TreeSitter::NodeMaps.for(tree_sitter_language)
        return nil unless node_map

        face = node_map[node_type]
        return nil unless face
        return nil unless enabled_faces.include?(face)

        face
      end

      def enabled_faces
        # カスタム feature 設定が優先
        if CONFIG[:tree_sitter_enabled_features]
          return CONFIG[:tree_sitter_enabled_features]
        end

        # レベルベースの制御
        level = CONFIG[:tree_sitter_highlight_level] || 3
        HIGHLIGHT_LEVELS.take(level).flatten
      end

    end
  end

  # Window モンキーパッチ
  class Window
    unless method_defined?(:original_highlight)
      alias_method :original_highlight, :highlight

      def highlight
        if @buffer&.mode.respond_to?(:custom_highlight)
          @buffer.mode.custom_highlight(self)
        else
          original_highlight
        end
      end
    end
  end
end
