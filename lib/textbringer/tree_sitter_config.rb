# frozen_string_literal: true

require "rbconfig"

module Textbringer
  module TreeSitterConfig
    class << self
      def platform
        os = case RbConfig::CONFIG["host_os"]
             when /darwin/i then "darwin"
             when /linux/i then "linux"
             else "unknown"
             end

        arch = case RbConfig::CONFIG["host_cpu"]
               when /arm64|aarch64/i then "arm64"
               when /x86_64|amd64/i then "x64"
               else "unknown"
               end

        "#{os}-#{arch}"
      end

      def dylib_ext
        case RbConfig::CONFIG["host_os"]
        when /darwin/i then ".dylib"
        else ".so"
        end
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
        filename = "libtree-sitter-#{language}#{dylib_ext}"

        # 検索パスから parser を探す
        parser_search_paths.each do |dir|
          path = File.join(dir, filename)
          return path if File.exist?(path)
        end

        # 見つからない場合はデフォルトパスを返す
        File.join(parser_search_paths.last, filename)
      end

      def parser_available?(language)
        filename = "libtree-sitter-#{language}#{dylib_ext}"

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
