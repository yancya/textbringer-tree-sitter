# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      JAVASCRIPT_FEATURES = {
        comment: %i[
          comment
          html_comment
          hash_bang_line
        ],
        string: %i[
          string
          string_fragment
          template_string
          template_substitution
          regex
          regex_pattern
          regex_flags
          escape_sequence
          html_character_reference
          jsx_text
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
          target
          meta
        ],
        number: %i[number],
        constant: %i[],
        function_name: %i[
          function_declaration
          function_expression
          generator_function
          generator_function_declaration
          arrow_function
          method_definition
          call_expression
        ],
        variable: %i[
          identifier
          property_identifier
          shorthand_property_identifier
          shorthand_property_identifier_pattern
          private_property_identifier
          statement_identifier
        ],
        type: %i[],
        operator: %i[
          binary_expression
          unary_expression
          update_expression
          ternary_expression
          assignment_expression
          augmented_assignment_expression
          optional_chain
        ],
        punctuation: %i[],
        builtin: %i[
          true
          false
          null
          undefined
          arguments
        ],
        property: %i[
          array
          object
          pair
          spread_element
          rest_pattern
          member_expression
          subscript_expression
          computed_property_name
          field_definition
          class_body
          class_declaration
          class_heritage
          class_static_block
          decorator
          statement_block
          expression_statement
          lexical_declaration
          variable_declaration
          variable_declarator
          parenthesized_expression
          sequence_expression
          formal_parameters
          assignment_pattern
          object_pattern
          array_pattern
          object_assignment_pattern
          pair_pattern
          if_statement
          else_clause
          switch_statement
          switch_body
          switch_case
          switch_default
          for_statement
          for_in_statement
          while_statement
          do_statement
          try_statement
          catch_clause
          finally_clause
          break_statement
          continue_statement
          return_statement
          throw_statement
          empty_statement
          labeled_statement
          with_statement
          debugger_statement
          export_statement
          export_clause
          export_specifier
          namespace_export
          import_statement
          import_clause
          import_specifier
          import_attribute
          namespace_import
          named_imports
          new_expression
          yield_expression
          await_expression
          meta_property
          program
        ]
      }.freeze

      JAVASCRIPT = JAVASCRIPT_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
