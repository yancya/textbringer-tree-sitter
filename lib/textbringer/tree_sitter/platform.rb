# frozen_string_literal: true

require "rbconfig"

module Textbringer
  module TreeSitter
    module Platform
      class << self
        # Detect OS and architecture
        # @return [String] platform string in format "os-arch" (e.g., "darwin-arm64", "linux-x64")
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

        # Get dynamic library extension for current platform
        # @return [String] ".dylib" for macOS, ".so" for others
        def dylib_ext
          case RbConfig::CONFIG["host_os"]
          when /darwin/i then ".dylib"
          else ".so"
          end
        end

        # Convert platform string to Faveod naming convention
        # @return [String] Faveod platform name (e.g., "macos-arm64", "linux-x64")
        def faveod_platform
          case platform
          when "darwin-arm64" then "macos-arm64"
          when "darwin-x64" then "macos-x64"
          when "linux-x64" then "linux-x64"
          when "linux-arm64" then "linux-arm64"
          else platform
          end
        end
      end
    end
  end
end
