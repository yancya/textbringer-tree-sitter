# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      JAVASCRIPT_FEATURES = {
        comment: %i[comment],
        string: %i[
          string
          template_string
          regex
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
          function
          class
          extends
          new
          this
          super
          import
          export
          from
          as
          const
          let
          var
          in
          of
          instanceof
          typeof
          void
          delete
          async
          await
          yield
          static
          get
          set
          debugger
          with
        ],
        number: %i[number],
        constant: %i[],
        function_name: %i[],
        variable: %i[
          identifier
          property_identifier
          shorthand_property_identifier
        ],
        type: %i[],
        operator: %i[],
        punctuation: %i[],
        builtin: %i[
          true
          false
          null
          undefined
        ],
        property: %i[]
      }.freeze

      JAVASCRIPT = JAVASCRIPT_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
