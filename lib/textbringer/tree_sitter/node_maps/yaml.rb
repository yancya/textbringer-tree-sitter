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
          plain_scalar
          escape_sequence
        ],
        keyword: %i[
          anchor
          anchor_name
          alias
          alias_name
          tag
          tag_handle
          tag_prefix
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
          stream
          document
          block_node
          flow_node
          block_mapping
          block_mapping_pair
          block_sequence
          block_sequence_item
          flow_mapping
          flow_sequence
          flow_pair
          directive_name
          directive_parameter
          yaml_directive
          yaml_version
          tag_directive
          reserved_directive
          timestamp_scalar
        ]
      }.freeze

      YAML_LANG = YAML_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
