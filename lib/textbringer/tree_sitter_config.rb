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

      def parser_dir
        File.expand_path("../../../parsers/#{platform}", __FILE__)
      end

      def parser_path(language)
        File.join(parser_dir, "libtree-sitter-#{language}#{dylib_ext}")
      end

      def parser_available?(language)
        File.exist?(parser_path(language))
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
