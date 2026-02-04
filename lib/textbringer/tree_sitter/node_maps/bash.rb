# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      BASH_FEATURES = {
        comment: %i[comment],
        string: %i[
          string
          raw_string
          heredoc_body
          heredoc_start
          ansi_c_string
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
          time
          coproc
        ],
        number: %i[],
        constant: %i[],
        function_name: %i[function_definition],
        variable: %i[
          variable_name
          special_variable_name
        ],
        type: %i[],
        operator: %i[
          file_redirect
          heredoc_redirect
          herestring_redirect
        ],
        punctuation: %i[],
        builtin: %i[],
        property: %i[]
      }.freeze

      BASH = BASH_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
