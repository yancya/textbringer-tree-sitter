# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      # Feature-based node mapping for Elixir
      ELIXIR_FEATURES = {
        comment: %i[comment],
        string: %i[
          string
          quoted_content
          charlist
          sigil
          atom
          quoted_atom
          interpolation
          escape_sequence
        ],
        keyword: %i[
          do
          end
          def
          defp
          defmodule
          defmacro
          defmacrop
          defstruct
          defimpl
          defprotocol
          if
          else
          unless
          cond
          case
          when
          fn
          for
          with
          receive
          after
          rescue
          catch
          raise
          try
          quote
          unquote
          import
          require
          alias
          use
        ],
        number: %i[integer float],
        constant: %i[
          boolean
          nil
          atom
          module
        ],
        function_name: %i[
          call
          identifier
        ],
        variable: %i[
          identifier
        ],
        operator: %i[
          operator
          binary_operator
          unary_operator
          arrow
          pipe
          range
          stab_clause
        ],
        punctuation: %i[],
        builtin: %i[true false nil],
        property: %i[
          list
          tuple
          map
          keyword_list
          struct
          bitstring
        ]
      }.freeze

      # Expand Feature -> Face mapping
      ELIXIR = ELIXIR_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
