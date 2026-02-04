# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      PHP_FEATURES = {
        comment: %i[comment],
        string: %i[
          string
          encapsed_string
          heredoc
          nowdoc
          shell_command_expression
        ],
        keyword: %i[
          if
          else
          elseif
          endif
          for
          foreach
          endforeach
          while
          endwhile
          do
          switch
          case
          default
          endswitch
          break
          continue
          return
          throw
          try
          catch
          finally
          function
          fn
          class
          interface
          trait
          extends
          implements
          namespace
          use
          as
          const
          public
          private
          protected
          static
          final
          abstract
          readonly
          new
          clone
          instanceof
          insteadof
          global
          echo
          print
          include
          include_once
          require
          require_once
          goto
          yield
          match
          enum
        ],
        number: %i[
          integer
          float
        ],
        constant: %i[],
        function_name: %i[],
        variable: %i[
          variable_name
          name
        ],
        type: %i[
          primitive_type
          named_type
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

      PHP = PHP_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
