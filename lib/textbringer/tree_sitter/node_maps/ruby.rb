# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      # Feature-based ノードマッピング
      # Emacs の treesit-font-lock-rules 風に feature ごとに分類
      RUBY_FEATURES = {
        comment: %i[comment],
        string: %i[
          string_content
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
          regex
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
        ],
        number: %i[integer float complex rational],
        constant: %i[
          constant
          encoding
          file
          line
        ],
        function_name: %i[],
        variable: %i[
          identifier
          instance_variable
          class_variable
          global_variable
          forward_argument
          forward_parameter
        ],
        type: %i[],
        operator: %i[
          operator
        ],
        punctuation: %i[
          empty_statement
        ],
        builtin: %i[nil true false hash_splat_nil],
        property: %i[]
      }.freeze

      # Feature → Face の展開
      RUBY = RUBY_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
