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
          heredoc_content
          heredoc_body
          simple_symbol
          delimited_symbol
          bare_symbol
          escape_sequence
          character
          subshell
          regex
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
        constant: %i[constant],
        function_name: %i[
          method
          singleton_method
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
        property: %i[hash array block]
      }.freeze

      # Feature → Face の展開
      RUBY = RUBY_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
