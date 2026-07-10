# frozen_string_literal: true

require_relative "language_aliases"
require_relative "injection_maps/ruby"

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
    #
    # Two tiers, mirroring NodeMaps: gem-bundled defaults (constants under
    # injection_maps/, e.g. injection_maps/ruby.rb's InjectionMaps::RUBY) and
    # user-registered custom entries (added via `register`, wiped by `clear`).
    # `for` returns both combined; `clear` only affects the custom tier, so
    # bundled defaults survive it.
    module InjectionMaps
      class << self
        def register(language, entries)
          @custom_maps ||= {}
          @custom_maps[LanguageAliases.to_sym(language)] = entries
        end

        def for(language)
          normalized = LanguageAliases.to_sym(language)
          combined = default_entries(normalized) + custom_entries(normalized)
          combined.empty? ? nil : combined
        end

        def clear
          @custom_maps = {}
        end

        private

        def default_maps
          {
            ruby: RUBY
          }
        end

        def default_entries(normalized)
          default_maps[normalized] || []
        end

        def custom_entries(normalized)
          (@custom_maps ||= {})[normalized] || []
        end
      end
    end
  end
end
