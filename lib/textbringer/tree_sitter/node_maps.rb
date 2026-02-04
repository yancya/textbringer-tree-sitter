# frozen_string_literal: true

require_relative "node_maps/ruby"
require_relative "node_maps/hcl"
require_relative "node_maps/bash"
require_relative "node_maps/c"
require_relative "node_maps/csharp"
require_relative "node_maps/cobol"
require_relative "node_maps/groovy"
require_relative "node_maps/haml"
require_relative "node_maps/html"
require_relative "node_maps/java"
require_relative "node_maps/javascript"
require_relative "node_maps/json"
require_relative "node_maps/pascal"
require_relative "node_maps/php"
require_relative "node_maps/python"
require_relative "node_maps/rust"
require_relative "node_maps/sql"
require_relative "node_maps/yaml"

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
          (default_maps.keys + (@custom_maps&.keys || [])).uniq
        end

        private

        def default_maps
          {
            ruby: RUBY,
            hcl: HCL,
            bash: BASH,
            c: C,
            csharp: CSHARP,
            cobol: COBOL,
            groovy: GROOVY,
            haml: HAML,
            html: HTML,
            java: JAVA,
            javascript: JAVASCRIPT,
            json: JSON_LANG,
            pascal: PASCAL,
            php: PHP,
            python: PYTHON,
            rust: RUST,
            sql: SQL,
            yaml: YAML_LANG
          }
        end
      end
    end
  end
end
