# frozen_string_literal: true

module Textbringer
  module TreeSitter
    module NodeMaps
      # JSON_LANG - Ruby の JSON モジュールと名前衝突を避けるため
      JSON_FEATURES = {
        comment: %i[],
        string: %i[string],
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
        property: %i[pair]
      }.freeze

      JSON_LANG = JSON_FEATURES.flat_map { |face, nodes|
        nodes.map { |node| [node, face] }
      }.to_h.freeze
    end
  end
end
