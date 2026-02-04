# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      JAVA_FEATURES = {
        comment: %i[
          comment
          line_comment
          block_comment
        ],
        string: %i[
          string_literal
          character_literal
          text_block
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
          throw
          try
          catch
          finally
          class
          interface
          enum
          record
          extends
          implements
          import
          package
          public
          private
          protected
          static
          final
          abstract
          synchronized
          native
          transient
          volatile
          strictfp
          new
          this
          super
          instanceof
          void
          assert
          throws
          permits
          sealed
          non
          var
          yield
        ],
        number: %i[
          decimal_integer_literal
          hex_integer_literal
          octal_integer_literal
          binary_integer_literal
          decimal_floating_point_literal
          hex_floating_point_literal
        ],
        constant: %i[],
        function_name: %i[],
        variable: %i[identifier],
        type: %i[
          type_identifier
          void_type
          integral_type
          floating_point_type
          boolean_type
        ],
        operator: %i[],
        punctuation: %i[],
        builtin: %i[
          true
          false
          null
        ],
        property: %i[]
      }.freeze

      JAVA = JAVA_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
