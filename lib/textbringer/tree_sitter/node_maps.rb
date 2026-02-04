# frozen_string_literal: true

require_relative "node_maps/ruby"
require_relative "node_maps/hcl"

module Textbringer
  module TreeSitter
    module NodeMaps
      class << self
        def for(language)
          # カスタムマップが登録されていれば、デフォルトとマージして返す
          if @custom_maps&.key?(language)
            default_map = default_maps[language]
            if default_map
              default_map.merge(@custom_maps[language])
            else
              @custom_maps[language]
            end
          else
            default_maps[language]
          end
        end

        def register(language, node_map)
          @custom_maps ||= {}
          @custom_maps[language] = node_map
        end

        def clear_custom_maps
          @custom_maps = {}
        end

        def available_languages
          default_maps.keys
        end

        private

        def default_maps
          {
            ruby: RUBY,
            hcl: HCL
          }
        end
      end
    end
  end
end
