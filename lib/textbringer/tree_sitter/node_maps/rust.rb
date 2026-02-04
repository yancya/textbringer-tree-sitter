# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      RUST_FEATURES = {
        comment: %i[
          line_comment
          block_comment
        ],
        string: %i[
          string_literal
          char_literal
          raw_string_literal
        ],
        keyword: %i[
          if
          else
          for
          while
          loop
          break
          continue
          return
          fn
          let
          mut
          const
          static
          struct
          enum
          union
          impl
          trait
          type
          mod
          use
          pub
          crate
          self
          super
          as
          in
          ref
          move
          dyn
          async
          await
          match
          where
          unsafe
          extern
          default
        ],
        number: %i[
          integer_literal
          float_literal
        ],
        constant: %i[],
        function_name: %i[],
        variable: %i[identifier],
        type: %i[
          type_identifier
          primitive_type
          generic_type
        ],
        operator: %i[],
        punctuation: %i[],
        builtin: %i[
          true
          false
        ],
        property: %i[field_identifier]
      }.freeze

      RUST = RUST_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
