# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      CSHARP_FEATURES = {
        comment: %i[comment],
        string: %i[
          string_literal
          verbatim_string_literal
          interpolated_string_expression
          character_literal
        ],
        keyword: %i[
          if
          else
          for
          foreach
          while
          do
          switch
          case
          default
          break
          continue
          return
          goto
          throw
          try
          catch
          finally
          class
          struct
          interface
          enum
          namespace
          using
          public
          private
          protected
          internal
          static
          readonly
          const
          volatile
          virtual
          override
          abstract
          sealed
          new
          this
          base
          void
          var
          async
          await
          yield
          in
          out
          ref
          params
          where
          get
          set
          add
          remove
          partial
          extern
          unsafe
          fixed
          lock
          checked
          unchecked
          stackalloc
          sizeof
          typeof
          nameof
          is
          as
          null
          true
          false
        ],
        number: %i[
          integer_literal
          real_literal
        ],
        constant: %i[],
        function_name: %i[],
        variable: %i[identifier],
        type: %i[
          predefined_type
          type_identifier
          generic_name
        ],
        operator: %i[],
        punctuation: %i[],
        builtin: %i[],
        property: %i[]
      }.freeze

      CSHARP = CSHARP_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
