# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      # HCL (HashiCorp Configuration Language) Feature-based ノードマッピング
      # Rouge の Terraform lexer では認識されない for, in, function_call を正しく処理
      HCL_FEATURES = {
        comment: %i[comment],
        string: %i[
          string_literal
          quoted_template
          heredoc
          template_expr
          escape_sequence
        ],
        keyword: %i[
          for
          in
          if
          true
          false
          null
        ],
        number: %i[numeric_literal],
        constant: %i[],
        function_name: %i[function_call],
        variable: %i[
          identifier
          variable_expr
        ],
        type: %i[],
        operator: %i[
          binary_op
          unary_op
          operation
          conditional
        ],
        punctuation: %i[],
        builtin: %i[],
        property: %i[
          attribute
          block
          body
          one_line_block
          object
          object_elem
          collection_value
          tuple
          literal_value
          expr_term
          expression
          for_expr
          for_intro
          for_cond
          source_file
          get_attr
          index
          splat
          splat_attr
          splat_full
        ]
      }.freeze

      # Feature → Face の展開
      HCL = HCL_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
