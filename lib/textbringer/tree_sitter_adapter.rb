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

        include InstanceMethods

        define_method(:tree_sitter_language) do
          language
        end
      end

      attr_reader :tree_sitter_language
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
        tree = parser.parse_string(nil, buffer_text)
        return unless tree

        highlight_on = {}
        highlight_off = {}

        visit_node(tree.root_node) do |node, start_byte, end_byte|
          face = node_type_to_face(node.type.to_sym)
          next unless face

          attrs = Face[face]&.attributes
          if attrs
            # base_pos + offset でバッファ内の絶対位置を計算
            highlight_on[base_pos + start_byte] = attrs
            highlight_off[base_pos + end_byte] = attrs
          end
        end

        window.instance_variable_set(:@highlight_on, highlight_on)
        window.instance_variable_set(:@highlight_off, highlight_off)
      end

      private

      def can_highlight?
        return false unless CONFIG[:colors] != false
        return false if CONFIG[:syntax_highlight] == false

        true
      end

      def get_parser
        @parser ||= begin
          return nil unless TreeSitterConfig.parser_available?(tree_sitter_language)

          require "tree_sitter"

          parser_path = TreeSitterConfig.parser_path(tree_sitter_language)
          language = ::TreeSitter::Language.load(
            tree_sitter_language.to_s,
            parser_path
          )

          parser = ::TreeSitter::Parser.new
          parser.language = language
          parser
        rescue LoadError, ::TreeSitter::TreeSitterError, ::TreeSitter::LanguageLoadError
          nil
        end
      end

      def visit_node(node, &block)
        block.call(node, node.start_byte, node.end_byte)

        node.child_count.times do |i|
          child = node.child(i)
          visit_node(child, &block) if child
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
