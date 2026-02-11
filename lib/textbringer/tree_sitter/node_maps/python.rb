# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      PYTHON_FEATURES = {
        comment: %i[comment],
        string: %i[
          string
          string_content
          string_start
          string_end
          concatenated_string
          escape_sequence
          escape_interpolation
          interpolation
          format_specifier
          format_expression
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
          type
          exec
          print
          __future__
        ],
        number: %i[
          integer
          float
        ],
        constant: %i[],
        function_name: %i[
          function_definition
          call
        ],
        variable: %i[
          identifier
          dotted_name
        ],
        type: %i[
          type
          generic_type
          member_type
          union_type
          constrained_type
          splat_type
        ],
        operator: %i[
          binary_operator
          unary_operator
          boolean_operator
          comparison_operator
          not_operator
          assignment
          augmented_assignment
          named_expression
          conditional_expression
        ],
        punctuation: %i[
          chevron
          ellipsis
          line_continuation
        ],
        builtin: %i[
          true
          false
          none
        ],
        property: %i[
          attribute
          argument_list
          keyword_argument
          keyword_separator
          default_parameter
          typed_default_parameter
          typed_parameter
          type_parameter
          list_splat
          dictionary_splat
          parameters
          lambda_parameters
          parenthesized_expression
          tuple
          tuple_pattern
          list
          list_pattern
          list_comprehension
          dictionary
          dict_pattern
          dictionary_comprehension
          set
          set_comprehension
          for_in_clause
          if_clause
          generator_expression
          parenthesized_list_splat
          expression_list
          pattern_list
          subscript
          slice
          expression_statement
          return_statement
          delete_statement
          raise_statement
          assert_statement
          print_statement
          pass_statement
          break_statement
          continue_statement
          if_statement
          elif_clause
          else_clause
          match_statement
          case_clause
          for_statement
          while_statement
          try_statement
          except_clause
          except_group_clause
          finally_clause
          with_statement
          with_clause
          with_item
          function_definition
          class_definition
          decorated_definition
          decorator
          block
          module
          import_statement
          import_from_statement
          import_prefix
          relative_import
          aliased_import
          future_import_statement
          wildcard_import
          global_statement
          nonlocal_statement
          exec_statement
          type_alias_statement
          as_pattern
          case_pattern
          keyword_pattern
          splat_pattern
          union_pattern
          complex_pattern
          dictionary_splat_pattern
          pair
        ]
      }.freeze

      PYTHON = PYTHON_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
