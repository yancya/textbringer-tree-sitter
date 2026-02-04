# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      # YAML_LANG - Ruby の YAML モジュールと名前衝突を避けるため
      YAML_FEATURES = {
        comment: %i[comment],
        string: %i[
          string_scalar
          double_quote_scalar
          single_quote_scalar
          block_scalar
        ],
        keyword: %i[
          anchor
          alias
          tag
        ],
        number: %i[
          integer_scalar
          float_scalar
        ],
        constant: %i[],
        function_name: %i[],
        variable: %i[],
        type: %i[],
        operator: %i[],
        punctuation: %i[],
        builtin: %i[
          boolean_scalar
          null_scalar
        ],
        property: %i[
          block_mapping_pair
          flow_pair
        ]
      }.freeze

      YAML_LANG = YAML_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
