# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      HTML_FEATURES = {
        comment: %i[comment],
        string: %i[
          attribute_value
          quoted_attribute_value
        ],
        keyword: %i[doctype],
        number: %i[],
        constant: %i[],
        function_name: %i[],
        variable: %i[],
        type: %i[],
        operator: %i[],
        punctuation: %i[],
        builtin: %i[],
        property: %i[
          tag_name
          attribute_name
          erroneous_end_tag_name
        ]
      }.freeze

      HTML = HTML_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
