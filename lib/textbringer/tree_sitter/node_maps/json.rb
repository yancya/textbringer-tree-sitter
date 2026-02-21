# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      # JSON_LANG - named to avoid conflict with Ruby's JSON module
      JSON_FEATURES = {
        comment: %i[comment],
        string: %i[
          string
          string_content
          escape_sequence
        ],
        keyword: %i[],
        number: %i[number],
        constant: %i[],
        function_name: %i[],
        variable: %i[],
        type: %i[],
        operator: %i[],
        punctuation: %i[],
        builtin: %i[
          true
          false
          null
        ],
        property: %i[
          pair
          array
          object
          document
        ]
      }.freeze

      JSON_LANG = JSON_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
