# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      # Crystal language node mapping
      # Based on crystal-lang-tools/tree-sitter-crystal
      # Crystal has Ruby-like syntax with static typing
      CRYSTAL_FEATURES = {
        comment: %i[comment],
        string: %i[
          string
          string_literal
          string_content
          heredoc_content
          heredoc_body
          symbol
          simple_symbol
          char_literal
          escape_sequence
          regex
          regex_literal
          command
        ],
        keyword: %i[
          def
          end
          class
          module
          struct
          if
          else
          elsif
          unless
          case
          when
          then
          while
          until
          for
          do
          break
          next
          redo
          return
          yield
          begin
          rescue
          ensure
          and
          or
          not
          in
          alias
          abstract
          private
          protected
          getter
          setter
          property
          include
          extend
          require
          lib
          fun
          macro
          annotation
          self
          super
          nil
          true
          false
          typeof
          sizeof
          offsetof
          pointerof
          as
          is_a?
          responds_to?
          uninitialized
          out
          with
        ],
        number: %i[
          integer
          float
          number_literal
          integer_literal
          float_literal
        ],
        constant: %i[
          constant
          type_identifier
          class_name
        ],
        function_name: %i[
          method
          method_name
          function_identifier
          call
        ],
        variable: %i[
          identifier
          instance_variable
          class_variable
          global_variable
          parameter
          variable
        ],
        type: %i[
          type
          generic_type
          union_type
          nilable_type
          proc_type
          tuple_type
        ],
        operator: %i[
          binary
          unary
          assignment
          operator
          binary_operator
          unary_operator
        ],
        punctuation: %i[],
        builtin: %i[],
        property: %i[
          hash
          array
          tuple
          named_tuple
          block
          attribute
        ]
      }.freeze

      # Expand Feature -> Face mapping
      CRYSTAL = CRYSTAL_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
