# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      SWIFT_FEATURES = {
        comment: %i[
          comment
          line_comment
          block_comment
          multiline_comment
        ],
        string: %i[
          line_string_literal
          multi_line_string_literal
          raw_string_literal
          string_literal
          interpolated_string_literal
        ],
        keyword: %i[
          if
          else
          switch
          case
          default
          for
          while
          repeat
          break
          continue
          return
          func
          var
          let
          class
          struct
          enum
          protocol
          extension
          typealias
          import
          init
          deinit
          subscript
          static
          final
          override
          mutating
          nonmutating
          convenience
          required
          lazy
          private
          fileprivate
          internal
          public
          open
          weak
          unowned
          throws
          rethrows
          try
          catch
          guard
          defer
          do
          where
          in
          inout
          associatedtype
          precedencegroup
          operator
          prefix
          postfix
          infix
          indirect
          dynamic
          optional
          some
          any
          async
          await
        ],
        number: %i[
          integer_literal
          float_literal
          hex_literal
          oct_literal
          bin_literal
        ],
        constant: %i[],
        function_name: %i[
          function_declaration
          method_declaration
        ],
        variable: %i[
          simple_identifier
          identifier
          parameter
        ],
        type: %i[
          type_identifier
          class_declaration
          struct_declaration
          enum_declaration
          protocol_declaration
        ],
        operator: %i[
          binary_expression
          prefix_expression
          postfix_expression
        ],
        punctuation: %i[],
        builtin: %i[
          nil
          true
          false
          self
          super
          Self
        ],
        property: %i[
          property_declaration
          computed_property
        ]
      }.freeze

      SWIFT = SWIFT_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
