# frozen_string_literal: true

require_relative "language_aliases"

module Textbringer
  module TreeSitter
    # Registry of per-language injection rules: which host node types
    # embed another language, and how to resolve which language.
    #
    # Each entry is a Hash:
    #   node_type: Symbol -- the host node type to scan for (e.g. :heredoc_body)
    #   content:   Symbol -- the child node type whose byte range gets the
    #                        injected highlighting (e.g. :heredoc_content)
    #   language:  Symbol or Proc(node, source) -- the injected language,
    #                        static or resolved dynamically per match
    module InjectionMaps
      class << self
        def register(language, entries)
          @maps ||= {}
          @maps[LanguageAliases.to_sym(language)] = entries
        end

        def for(language)
          (@maps ||= {})[LanguageAliases.to_sym(language)]
        end

        def clear
          @maps = {}
        end
      end
    end
  end
end
