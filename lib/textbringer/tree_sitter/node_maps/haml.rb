# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      HAML_FEATURES = {
        comment: %i[comment],
        string: %i[
          string
          string_content
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
          id
          class
          attribute_name
        ]
      }.freeze

      HAML = HAML_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
