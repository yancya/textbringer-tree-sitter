#!/usr/bin/env ruby
# frozen_string_literal: true

# gem install 時にプリビルド済み parser を自動ダウンロード
# Faveod/tree-sitter-parsers から tarball を取得して展開

require "fileutils"
require "open-uri"
require "tmpdir"
require "digest"
require "json"
require "rubygems/package"
require "zlib"
require_relative "../../lib/textbringer/tree_sitter/platform"

def platform
  Textbringer::TreeSitter::Platform.platform
end

def faveod_platform
  Textbringer::TreeSitter::Platform.faveod_platform
end

def dylib_ext
  Textbringer::TreeSitter::Platform.dylib_ext
end

PARSER_DIR = File.expand_path("~/.textbringer/parsers/#{platform}")
FAVEOD_VERSION = "v4.11"
CHECKSUMS_FILE = File.expand_path("~/.textbringer/parsers/checksums.json")

# 自動インストールする言語
DEFAULT_PARSERS = %w[ruby python javascript json bash]

def load_checksums
  return {} unless File.exist?(CHECKSUMS_FILE)

  begin
    JSON.parse(File.read(CHECKSUMS_FILE))
  rescue => e
    warn "Warning: Failed to load checksums: #{e.message}"
    {}
  end
end

def save_checksums(checksums)
  FileUtils.mkdir_p(File.dirname(CHECKSUMS_FILE))
  File.write(CHECKSUMS_FILE, JSON.pretty_generate(checksums))
end

def compute_checksum(file_path)
  Digest::SHA256.file(file_path).hexdigest
end

def verify_checksum(file_path, url)
  checksums = load_checksums
  actual = compute_checksum(file_path)

  if checksums.key?(url)
    expected = checksums[url]
    if actual != expected
      raise "Checksum verification failed for #{url}\n" \
            "  Expected: #{expected}\n" \
            "  Got:      #{actual}"
    end
    puts "    Checksum verified: #{actual[0..15]}..."
  else
    # First download - record checksum
    checksums[url] = actual
    save_checksums(checksums)
    puts "    Checksum recorded: #{actual[0..15]}..."
  end
end

def extract_tarball(tarball_path, extract_dir)
  File.open(tarball_path, "rb") do |file|
    Zlib::GzipReader.wrap(file) do |gz|
      Gem::Package::TarReader.new(gz) do |tar|
        tar.each do |entry|
          next unless entry.file?
          dest = File.join(extract_dir, entry.full_name)
          FileUtils.mkdir_p(File.dirname(dest))
          File.open(dest, "wb") { |f| f.write(entry.read) }
        end
      end
    end
  end
  true
rescue Zlib::GzipFile::Error, Gem::Package::TarInvalidError => e
  puts "  Error: Failed to extract tarball: #{e.message}"
  false
end

def download_and_extract_parsers
  # Check for opt-out environment variable
  if ENV["TEXTBRINGER_TREE_SITTER_NO_DOWNLOAD"]
    puts "  Skipping parser download (TEXTBRINGER_TREE_SITTER_NO_DOWNLOAD is set)"
    puts ""
    puts "  To install parsers manually:"
    puts "    1. Download from https://github.com/Faveod/tree-sitter-parsers/releases"
    puts "    2. Extract to #{PARSER_DIR}"
    puts "    3. Or use: textbringer-tree-sitter get <lang>"
    return true
  end

  url = "https://github.com/Faveod/tree-sitter-parsers/releases/download/#{FAVEOD_VERSION}/tree-sitter-parsers-#{FAVEOD_VERSION.delete('v')}-#{faveod_platform}.tar.gz"

  puts "  Downloading parsers from Faveod..."
  puts "  URL: #{url}"

  Dir.mktmpdir do |tmpdir|
    tarball = File.join(tmpdir, "parsers.tar.gz")

    begin
      URI.open(url, "rb") do |remote|
        File.open(tarball, "wb") do |local|
          local.write(remote.read)
        end
      end
    rescue OpenURI::HTTPError => e
      puts "  Error: Failed to download: #{e.message}"
      return false
    end

    # Verify checksum
    begin
      verify_checksum(tarball, url)
    rescue => e
      puts "  Error: #{e.message}"
      return false
    end

    # 展開
    extract_dir = File.join(tmpdir, "extracted")
    FileUtils.mkdir_p(extract_dir)

    unless extract_tarball(tarball, extract_dir)
      return false
    end

    # parser ファイルを探してコピー
    Dir.glob("#{extract_dir}/**/libtree-sitter-*#{dylib_ext}").each do |src|
      filename = File.basename(src)
      # libtree-sitter-{lang}.dylib の形式から lang を抽出
      lang = filename.sub(/^libtree-sitter-/, "").sub(/#{Regexp.escape(dylib_ext)}$/, "")

      if DEFAULT_PARSERS.include?(lang)
        dest = File.join(PARSER_DIR, filename)
        unless File.exist?(dest)
          FileUtils.cp(src, dest)
          FileUtils.chmod(0o755, dest)
          puts "    #{lang} -> OK"
        else
          puts "    #{lang} -> already installed"
        end
      end
    end
  end

  true
end

puts ""
puts "=" * 60
puts "textbringer-tree-sitter: Installing default parsers"
puts "=" * 60
puts "Platform: #{platform}"
puts "Directory: #{PARSER_DIR}"
puts ""

FileUtils.mkdir_p(PARSER_DIR)
download_and_extract_parsers

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
