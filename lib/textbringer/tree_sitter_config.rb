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

      # Parser を探索するディレクトリのリスト（優先順位順）
      def parser_search_paths
        paths = []

        # 1. CONFIG で指定されたカスタムパス（最優先）
        if defined?(CONFIG) && CONFIG[:tree_sitter_parser_dir]
          paths << CONFIG[:tree_sitter_parser_dir]
        end

        # 2. ~/.textbringer/parsers/{platform}（ユーザー共通）
        paths << File.expand_path("~/.textbringer/parsers/#{platform}")

        # 3. gem 内の parsers/{platform}（デフォルト）
        paths << File.expand_path("../../../parsers/#{platform}", __FILE__)

        paths
      end

      # 後方互換性のため、最初に見つかったパスを返す
      def parser_dir
        parser_search_paths.find { |path| Dir.exist?(path) } || parser_search_paths.last
      end

      def parser_path(language)
        # Normalize language name to handle aliases
        normalized = TreeSitter::LanguageAliases.normalize(language)
        filename = "libtree-sitter-#{normalized}#{dylib_ext}"

        # 検索パスから parser を探す
        parser_search_paths.each do |dir|
          path = File.join(dir, filename)
          return path if File.exist?(path)
        end

        # 見つからない場合はデフォルトパスを返す
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
