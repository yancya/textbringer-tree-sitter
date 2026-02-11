# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      HTML_FEATURES = {
        comment: %i[comment],
        string: %i[
          attribute_value
          quoted_attribute_value
          text
          raw_text
        ],
        keyword: %i[doctype],
        number: %i[],
        constant: %i[entity],
        function_name: %i[],
        variable: %i[],
        type: %i[],
        operator: %i[],
        punctuation: %i[],
        builtin: %i[],
        property: %i[
          document
          element
          script_element
          style_element
          start_tag
          end_tag
          self_closing_tag
          erroneous_end_tag
          tag_name
          attribute
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
