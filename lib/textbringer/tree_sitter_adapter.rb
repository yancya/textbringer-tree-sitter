# frozen_string_literal: true

require_relative "tree_sitter_config"
require_relative "tree_sitter/node_maps"

module Textbringer
  module TreeSitterAdapter
    # Emacs-style 4-level highlighting
    HIGHLIGHT_LEVELS = [
      %i[comment string],                    # Level 1: minimal
      %i[keyword type constant],             # Level 2: basic
      %i[function_name variable number],     # Level 3: standard (default)
      %i[operator punctuation builtin]       # Level 4: everything
    ].freeze

    module ClassMethods
      def use_tree_sitter(language)
        @tree_sitter_language = language
        @tree_sitter_enabled = true

        # Use prepend to take priority over existing custom_highlight
        prepend InstanceMethods

        define_method(:tree_sitter_language) do
          language
        end
      end

      def tree_sitter_enabled=(value)
        @tree_sitter_enabled = value
      end

      def tree_sitter_enabled?
        @tree_sitter_enabled
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
        # Same logic as textbringer core: use base_pos as the reference point
        base_pos = buffer.point_min
        buffer_text = buffer.to_s

        # Incremental parsing: reuse previous Tree if content unchanged
        old_tree = get_cached_tree(buffer, buffer_text)
        tree = parser.parse_string(old_tree, buffer_text)
        return unless tree

        # Cache the new Tree
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
            # Both Tree-sitter and Textbringer use byte offsets
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
          # LRU refresh: delete and re-insert to move to the end
          @tree_cache.delete(buffer_id)
          @tree_cache[buffer_id] = cached
          cached[:tree]
        else
          # Content changed or no cache -> full reparse
          @tree_cache.delete(buffer_id)
          nil
        end
      end

      def cache_tree(buffer, tree, buffer_text)
        @tree_cache ||= {}

        buffer_id = buffer.object_id

        # Delete existing entry and re-insert (LRU order update)
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
        # Same check as textbringer core: use @@has_colors
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
          # Leaf node: skip yield if already covered by the same face as parent
          block.call(node, node.start_byte, node.end_byte) unless my_face && my_face == covered_face
        else
          # Non-leaf node: yield if in node_map and face differs from parent
          if my_face && my_face != covered_face
            block.call(node, node.start_byte, node.end_byte)
          end
          # Recurse into children (propagate this node's face)
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
        # Custom feature settings take priority
        if CONFIG[:tree_sitter_enabled_features]
          return CONFIG[:tree_sitter_enabled_features]
        end

        # Level-based control
        level = CONFIG[:tree_sitter_highlight_level] || 3
        HIGHLIGHT_LEVELS.take(level).flatten
      end

    end
  end

  # Window monkey-patch
  class Window
    unless method_defined?(:original_highlight)
      alias_method :original_highlight, :highlight

      def highlight
        if @buffer&.mode.respond_to?(:custom_highlight) &&
            @buffer.mode.class.tree_sitter_enabled?
          @buffer.mode.custom_highlight(self)
        else
          original_highlight
        end
      end
    end
  end
end
