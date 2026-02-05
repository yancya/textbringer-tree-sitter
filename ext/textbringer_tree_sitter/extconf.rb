#!/usr/bin/env ruby
# frozen_string_literal: true

# gem install 時にプリビルド済み parser を自動ダウンロード
# Faveod/tree-sitter-parsers から tarball を取得して展開

require "fileutils"
require "open-uri"
require "rbconfig"
require "tmpdir"
require "digest/sha2"
require "json"

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

def faveod_platform
  case platform
  when "darwin-arm64" then "macos-arm64"
  when "darwin-x64" then "macos-x64"
  when "linux-x64" then "linux-x64"
  when "linux-arm64" then "linux-arm64"
  else platform
  end
end

def dylib_ext
  case RbConfig::CONFIG["host_os"]
  when /darwin/i then ".dylib"
  else ".so"
  end
end

PARSER_DIR = File.expand_path("~/.textbringer/parsers/#{platform}")
CHECKSUM_FILE = File.expand_path("~/.textbringer/parsers/checksums.json")
FAVEOD_VERSION = "v4.11"

# 自動インストールする言語
DEFAULT_PARSERS = %w[ruby python javascript json bash]

def load_checksums
  return {} unless File.exist?(CHECKSUM_FILE)

  JSON.parse(File.read(CHECKSUM_FILE))
rescue JSON::ParserError, Errno::ENOENT
  {}
end

def save_checksums(checksums)
  FileUtils.mkdir_p(File.dirname(CHECKSUM_FILE))
  File.write(CHECKSUM_FILE, JSON.pretty_generate(checksums))
end

def compute_sha256(file_path)
  Digest::SHA256.file(file_path).hexdigest
end

def verify_checksum(file_path, url)
  checksums = load_checksums
  computed = compute_sha256(file_path)

  if checksums.key?(url)
    stored = checksums[url]
    if stored != computed
      puts "  ERROR: Checksum verification failed!"
      puts "  Expected: #{stored}"
      puts "  Got:      #{computed}"
      puts "  This may indicate a corrupted download or tampering."
      return false
    end
    puts "  Checksum verified: #{computed[0..15]}..."
  else
    # First download - store the checksum
    checksums[url] = computed
    save_checksums(checksums)
    puts "  Checksum recorded: #{computed[0..15]}..."
  end

  true
end

def download_and_extract_parsers
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
    unless verify_checksum(tarball, url)
      puts "  Aborting installation due to checksum mismatch."
      return false
    end

    # 展開
    extract_dir = File.join(tmpdir, "extracted")
    FileUtils.mkdir_p(extract_dir)

    system("tar", "-xzf", tarball, "-C", extract_dir)

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
