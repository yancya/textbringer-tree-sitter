# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      # Feature-based ノードマッピング
      # Emacs の treesit-font-lock-rules 風に feature ごとに分類
      RUBY_FEATURES = {
        comment: %i[comment],
        string: %i[
          string
          string_content
          string_array
          symbol_array
          heredoc_content
          heredoc_body
          heredoc_beginning
          heredoc_end
          simple_symbol
          delimited_symbol
          bare_symbol
          hash_key_symbol
          bare_string
          escape_sequence
          character
          subshell
          regex
          chained_string
          interpolation
          uninterpreted
        ],
        keyword: %i[
          def
          end
          class
          module
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
          retry
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
          undef
          defined?
          self
          super
          BEGIN
          END
          lambda
          as
        ],
        number: %i[integer float complex rational],
        constant: %i[
          constant
          encoding
          file
          line
        ],
        function_name: %i[
          method
          singleton_method
          call
        ],
        variable: %i[
          identifier
          instance_variable
          class_variable
          global_variable
        ],
        type: %i[singleton_class],
        operator: %i[
          binary
          unary
          assignment
          operator
          operator_assignment
        ],
        punctuation: %i[],
        builtin: %i[nil true false],
        property: %i[
          hash
          array
          block
          hash_pattern
          array_pattern
          find_pattern
          hash_splat_argument
          hash_splat_nil
          hash_splat_parameter
          splat_argument
          splat_parameter
          rest_assignment
          pair
          argument_list
          block_argument
          block_body
          block_parameter
          block_parameters
          keyword_parameter
          keyword_pattern
          optional_parameter
          forward_argument
          forward_parameter
          destructured_parameter
          left_assignment_list
          right_assignment_list
          destructured_left_assignment
          lambda_parameters
          method_parameters
          parenthesized_pattern
          pattern
          alternative_pattern
          expression_reference_pattern
          variable_reference_pattern
          test_pattern
          body_statement
          parenthesized_statements
          program
          scope_resolution
          element_reference
          setter
          conditional
          if_modifier
          unless_modifier
          while_modifier
          until_modifier
          rescue_modifier
          case_match
          in_clause
          match_pattern
          if_guard
          unless_guard
          do_block
          begin_block
          end_block
          empty_statement
          expression
          exception_variable
          exceptions
        ]
      }.freeze

      # Feature → Face の展開
      RUBY = RUBY_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
