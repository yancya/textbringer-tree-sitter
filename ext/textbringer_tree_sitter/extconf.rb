#!/usr/bin/env ruby
# frozen_string_literal: true

# gem install 時にプリビルド済み parser を自動ダウンロード
# HCL, YAML などビルドが必要なものは `textbringer-tree-sitter get <lang>` で取得

require "fileutils"
require "open-uri"
require "rbconfig"

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

PARSER_DIR = File.expand_path("~/.textbringer/parsers/#{platform}")
FAVEOD_VERSION = "v0.1.0"

# プリビルド済みで自動ダウンロードする言語
PREBUILT_PARSERS = %w[ruby python javascript json bash]

def download_parser(language)
  filename = "libtree-sitter-#{language}#{dylib_ext}"
  dest_path = File.join(PARSER_DIR, filename)

  return if File.exist?(dest_path)

  url = "https://github.com/Faveod/tree-sitter-parsers/releases/download/#{FAVEOD_VERSION}/libtree-sitter-#{language}-#{platform}#{dylib_ext}"

  puts "  Downloading #{language}..."

  begin
    URI.open(url, "rb") do |remote|
      File.open(dest_path, "wb") do |local|
        local.write(remote.read)
      end
    end
    FileUtils.chmod(0o755, dest_path)
    puts "    -> OK"
  rescue OpenURI::HTTPError => e
    puts "    -> Failed: #{e.message}"
  rescue StandardError => e
    puts "    -> Error: #{e.class}: #{e.message}"
  end
end

puts ""
puts "=" * 60
puts "textbringer-tree-sitter: Installing default parsers"
puts "=" * 60
puts "Platform: #{platform}"
puts "Directory: #{PARSER_DIR}"
puts ""

FileUtils.mkdir_p(PARSER_DIR)

PREBUILT_PARSERS.each do |lang|
  download_parser(lang)
end

puts ""
puts "For additional parsers (HCL, YAML, Go, etc.):"
puts "  $ textbringer-tree-sitter get hcl"
puts "  $ textbringer-tree-sitter list"
puts "=" * 60
puts ""

# extconf.rb は Makefile を生成する必要がある
File.write("Makefile", <<~MAKEFILE)
  all:
  \t@:
  install:
  \t@:
  clean:
  \t@:
MAKEFILE
