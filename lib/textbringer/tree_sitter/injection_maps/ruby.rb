# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module InjectionMaps
      # Resolves the injected language from a Ruby heredoc's closing tag.
      # tree-sitter-ruby's heredoc_body always carries a heredoc_end child
      # whose text is the bare tag (e.g. "SQL"), regardless of whether the
      # opening delimiter was <<~SQL, <<SQL, or the quoted <<~'SQL' form --
      # verified against a live parse of all three (quoting only affects
      # heredoc_content escape/interpolation processing, not the tag itself).
      #
      # No parser-availability check happens here: an unrecognized or
      # unsupported tag still resolves to a Symbol, and the highlighting
      # engine's get_injected_parser (see tree_sitter_adapter.rb) already
      # skips gracefully when no matching parser is installed.
      RUBY_HEREDOC_LANGUAGE_RESOLVER = lambda { |host_node, source|
        tag_node = nil
        host_node.child_count.times do |i|
          child = host_node.child(i)
          tag_node = child if child && child.type.to_sym == :heredoc_end
        end
        next nil unless tag_node

        tag_text = source.byteslice(tag_node.start_byte, tag_node.end_byte - tag_node.start_byte)
        next nil if tag_text.nil? || tag_text.empty?

        LanguageAliases.to_sym(tag_text.downcase)
      }

      RUBY = [
        {
          node_type: :heredoc_body,
          content: :heredoc_content,
          language: RUBY_HEREDOC_LANGUAGE_RESOLVER
        }
      ].freeze
    end
  end
end
