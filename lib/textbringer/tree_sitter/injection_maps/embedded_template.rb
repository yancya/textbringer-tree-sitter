# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module InjectionMaps
      # ERB (Faveod's embedded-template grammar): Ruby code inside <% %> /
      # <%= %>, HTML everywhere else. Unlike the Ruby heredoc map, these are
      # static -- ERB's own grammar already separates code from content, no
      # per-match language resolution needed.
      #
      # :content entries use content == node_type ("self-injection"): a
      # `content` node IS the HTML text leaf, not a wrapper around one.
      EMBEDDED_TEMPLATE = [
        { node_type: :directive, content: :code, language: :ruby },
        { node_type: :output_directive, content: :code, language: :ruby },
        { node_type: :content, content: :content, language: :html }
      ].freeze
    end
  end
end
