# frozen_string_literal: true

require_relative "tree_sitter/platform"
require_relative "tree_sitter/language_aliases"

module Textbringer
  module TreeSitterConfig
    class << self
      def platform
        TreeSitter::Platform.platform
      end

      def dylib_ext
        TreeSitter::Platform.dylib_ext
      end

      # List of directories to search for parsers (in priority order)
      def parser_search_paths
        paths = []

        # 1. Custom path specified in CONFIG (highest priority)
        if defined?(CONFIG) && CONFIG[:tree_sitter_parser_dir]
          paths << CONFIG[:tree_sitter_parser_dir]
        end

        # 2. ~/.textbringer/parsers/{platform} (user-level shared)
        paths << File.expand_path("~/.textbringer/parsers/#{platform}")

        # 3. parsers/{platform} inside the gem (default)
        paths << File.expand_path("../../../parsers/#{platform}", __FILE__)

        paths
      end

      # For backward compatibility, return the first path found
      def parser_dir
        parser_search_paths.find { |path| Dir.exist?(path) } || parser_search_paths.last
      end

      def parser_path(language)
        # Normalize language name to handle aliases
        normalized = TreeSitter::LanguageAliases.normalize(language)
        filename = "libtree-sitter-#{normalized}#{dylib_ext}"

        # Search for parser in search paths
        parser_search_paths.each do |dir|
          path = File.join(dir, filename)
          return path if File.exist?(path)
        end

        # Return default path if not found
        File.join(parser_search_paths.last, filename)
      end

      def parser_available?(language)
        # Normalize language name to handle aliases
        normalized = TreeSitter::LanguageAliases.normalize(language)
        filename = "libtree-sitter-#{normalized}#{dylib_ext}"

        parser_search_paths.any? do |dir|
          File.exist?(File.join(dir, filename))
        end
      end

      def define_default_faces
        Face.define(:comment, foreground: "green")
        Face.define(:string, foreground: "cyan")
        Face.define(:keyword, foreground: "yellow")
        Face.define(:number, foreground: "magenta")
        Face.define(:constant, foreground: "magenta")
        Face.define(:function_name, foreground: "blue")
        Face.define(:type, foreground: "blue")
        Face.define(:variable, foreground: "white")
        Face.define(:operator, foreground: "white")
        Face.define(:punctuation, foreground: "white")
        Face.define(:builtin, foreground: "cyan")
        Face.define(:property, foreground: "cyan")
      end
    end
  end
end
