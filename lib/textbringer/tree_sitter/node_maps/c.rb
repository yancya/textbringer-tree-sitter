# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      C_FEATURES = {
        comment: %i[comment],
        string: %i[
          string_literal
          char_literal
          system_lib_string
        ],
        keyword: %i[
          if
          else
          for
          while
          do
          switch
          case
          default
          break
          continue
          return
          goto
          struct
          union
          enum
          typedef
          sizeof
          static
          extern
          const
          volatile
          inline
          register
          auto
          restrict
        ],
        number: %i[number_literal],
        constant: %i[],
        function_name: %i[function_declarator],
        variable: %i[identifier],
        type: %i[
          primitive_type
          type_identifier
          sized_type_specifier
        ],
        operator: %i[],
        punctuation: %i[],
        builtin: %i[
          true
          false
          null
        ],
        property: %i[field_identifier]
      }.freeze

      C = C_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
