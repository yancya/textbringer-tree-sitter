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
          ansi_c_string
          translated_string
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
          typeset
        ],
        number: %i[number],
        constant: %i[],
        function_name: %i[function_definition],
        variable: %i[
          variable_name
          special_variable_name
          variable_assignment
        ],
        type: %i[],
        operator: %i[
          file_redirect
          heredoc_redirect
          herestring_redirect
          test_operator
        ],
        punctuation: %i[],
        builtin: %i[
          test_command
          command_substitution
          process_substitution
          expansion
        ],
        property: %i[array]
      }.freeze

      BASH = BASH_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
