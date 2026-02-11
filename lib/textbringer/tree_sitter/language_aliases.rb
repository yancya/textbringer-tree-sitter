# frozen_string_literal: true

module Textbringer
  module TreeSitter
    # Centralized language name normalization and alias resolution
    #
    # Usage:
    #   LanguageAliases.normalize("c-sharp")  #=> "csharp"
    #   LanguageAliases.normalize("c_sharp")  #=> "csharp"
    #   LanguageAliases.normalize("CSharp")   #=> "csharp"
    module LanguageAliases
      # Canonical language names mapped to their aliases
      ALIASES = {
        "csharp" => ["c-sharp", "c_sharp", "cs"],
        "javascript" => ["js"],
        "typescript" => ["ts"],
        "python" => ["py"],
        "ruby" => ["rb"]
      }.freeze

      # Build reverse lookup: alias => canonical name
      ALIAS_TO_CANONICAL = ALIASES.flat_map { |canonical, aliases|
        aliases.map { |alias_name| [alias_name, canonical] }
      }.to_h.freeze

      class << self
        # Normalize a language name to its canonical form
        #
        # @param language [String, Symbol] Language name (e.g., "c-sharp", "C_Sharp", :csharp)
        # @return [String] Normalized canonical name (e.g., "csharp")
        #
        # Examples:
        #   normalize("c-sharp")   #=> "csharp"
        #   normalize("C_Sharp")   #=> "csharp"
        #   normalize(:csharp)     #=> "csharp"
        #   normalize("ruby")      #=> "ruby"
        def normalize(language)
          # Convert to string and lowercase
          name = language.to_s.downcase

          # Check exact match with known alias (e.g., "c-sharp", "js", "rb")
          return ALIAS_TO_CANONICAL[name] if ALIAS_TO_CANONICAL.key?(name)

          # Check separator-stripped match (e.g., "CSharp" → "csharp")
          stripped = name.tr("-_", "")
          return ALIAS_TO_CANONICAL[stripped] if ALIAS_TO_CANONICAL.key?(stripped)

          # Not aliased - return original name preserving separators
          # (e.g., "embedded-template" stays "embedded-template")
          name
        end

        # Convert a normalized canonical name to a symbol
        #
        # @param language [String, Symbol] Language name
        # @return [Symbol] Normalized canonical name as symbol
        #
        # Examples:
        #   to_sym("c-sharp")  #=> :csharp
        #   to_sym(:ruby)      #=> :ruby
        def to_sym(language)
          normalize(language).to_sym
        end
      end
    end
  end
end
