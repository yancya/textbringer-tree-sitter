# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      GROOVY_FEATURES = {
        comment: %i[comment],
        string: %i[
          string
          gstring
          string_content
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
          trait
          extends
          implements
          import
          package
          def
          var
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
          new
          this
          super
          instanceof
          in
          as
          assert
        ],
        number: %i[number_literal],
        constant: %i[],
        function_name: %i[],
        variable: %i[identifier],
        type: %i[type_identifier],
        operator: %i[],
        punctuation: %i[],
        builtin: %i[
          true
          false
          null
        ],
        property: %i[]
      }.freeze

      GROOVY = GROOVY_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
