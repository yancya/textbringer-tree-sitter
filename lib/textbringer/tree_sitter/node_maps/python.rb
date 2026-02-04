# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      PYTHON_FEATURES = {
        comment: %i[comment],
        string: %i[
          string
          string_content
          concatenated_string
        ],
        keyword: %i[
          if
          elif
          else
          for
          while
          break
          continue
          return
          pass
          raise
          try
          except
          finally
          with
          as
          def
          class
          lambda
          import
          from
          global
          nonlocal
          assert
          yield
          del
          in
          not
          and
          or
          is
          async
          await
          match
          case
        ],
        number: %i[
          integer
          float
        ],
        constant: %i[],
        function_name: %i[],
        variable: %i[identifier],
        type: %i[type],
        operator: %i[],
        punctuation: %i[],
        builtin: %i[
          true
          false
          none
        ],
        property: %i[attribute]
      }.freeze

      PYTHON = PYTHON_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
