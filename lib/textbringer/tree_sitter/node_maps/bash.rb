# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      BASH_FEATURES = {
        comment: %i[comment],
        string: %i[
          string
          string_content
          raw_string
          heredoc_body
          heredoc_content
          heredoc_start
          heredoc_end
          ansi_c_string
          translated_string
          escape_sequence
        ],
        keyword: %i[
          if
          then
          else
          elif
          fi
          for
          while
          until
          do
          done
          case
          esac
          in
          function
          select
          declare
          local
          readonly
          export
          unset
          unsetenv
          typeset
        ],
        number: %i[number],
        constant: %i[],
        function_name: %i[
          function_definition
          command
          command_name
        ],
        variable: %i[
          variable_name
          special_variable_name
          variable_assignment
          variable_assignments
        ],
        type: %i[],
        operator: %i[
          file_redirect
          heredoc_redirect
          herestring_redirect
          test_operator
          binary_expression
          unary_expression
          ternary_expression
          postfix_expression
        ],
        punctuation: %i[],
        builtin: %i[
          test_command
          command_substitution
          process_substitution
          expansion
          simple_expansion
          arithmetic_expansion
          brace_expression
        ],
        property: %i[
          array
          program
          statement
          redirected_statement
          for_statement
          c_style_for_statement
          while_statement
          if_statement
          elif_clause
          else_clause
          case_statement
          case_item
          pipeline
          list
          negated_command
          test_command
          declaration_command
          unset_command
          compound_statement
          subshell
          parenthesized_expression
          concatenation
          do_group
          word
          literal
          regex
          extglob_pattern
          subscript
          file_descriptor
        ]
      }.freeze

      BASH = BASH_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
