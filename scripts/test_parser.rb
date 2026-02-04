#!/usr/bin/env ruby
# frozen_string_literal: true

# Parser 動作確認スクリプト
# Usage: bundle exec ruby scripts/test_parser.rb [language] [file]

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "tree_sitter"
require "textbringer/tree_sitter_config"
require "textbringer/tree_sitter/node_maps"

# Textbringer モック
module Textbringer
  CONFIG = { colors: true }

  class Face
    @faces = {}

    class << self
      def [](name)
        @faces[name]
      end

      def define(name, **attrs)
        @faces[name] = new(name, attrs)
      end
    end

    attr_reader :name, :attributes

    def initialize(name, attrs)
      @name = name
      @attributes = attrs
    end
  end
end

Textbringer::TreeSitterConfig.define_default_faces

def colorize(text, face)
  colors = {
    comment: "\e[32m",       # green
    string: "\e[36m",        # cyan
    keyword: "\e[33m",       # yellow
    number: "\e[35m",        # magenta
    constant: "\e[35m",      # magenta
    function_name: "\e[34m", # blue
    type: "\e[34m",          # blue
    variable: "\e[37m",      # white
    builtin: "\e[36m",       # cyan
    property: "\e[36m"       # cyan
  }
  reset = "\e[0m"

  color = colors[face] || ""
  "#{color}#{text}#{reset}"
end

def collect_highlights(node, node_map, code)
  highlights = []
  visit_node(node, node_map, code, highlights)
  highlights.sort_by { |h| [h[:start], -h[:end]] }
end

def visit_node(node, node_map, code, highlights)
  node_type = node.type.to_sym
  face = node_map[node_type]

  if face
    highlights << {
      type: node_type,
      face: face,
      start: node.start_byte,
      end: node.end_byte,
      text: code[node.start_byte...node.end_byte]
    }
  end

  node.child_count.times do |i|
    child = node.child(i)
    visit_node(child, node_map, code, highlights) if child
  end
end

def print_highlighted_code(code, highlights)
  # 単純化のため、行単位でハイライト表示
  puts "\n=== Highlighted Code ==="
  highlights.each do |h|
    next if h[:text].include?("\n") # 複数行はスキップ

    puts "#{colorize(h[:text], h[:face])} (#{h[:face]})"
  end
end

def main
  language = (ARGV[0] || "ruby").to_sym
  file_path = ARGV[1]

  # Parser の存在確認
  unless Textbringer::TreeSitterConfig.parser_available?(language)
    puts "Parser not found for #{language}"
    puts "Parser path: #{Textbringer::TreeSitterConfig.parser_path(language)}"
    puts "\nAvailable languages with NodeMaps:"
    Textbringer::TreeSitter::NodeMaps.available_languages.each do |lang|
      available = Textbringer::TreeSitterConfig.parser_available?(lang)
      status = available ? "✓" : "✗"
      puts "  #{status} #{lang}"
    end
    exit 1
  end

  # NodeMap の存在確認
  node_map = Textbringer::TreeSitter::NodeMaps.for(language)
  unless node_map
    puts "NodeMap not found for #{language}"
    exit 1
  end

  # コードを読み込み
  code = if file_path
           File.read(file_path)
         else
           # サンプルコード
           case language
           when :ruby
             <<~RUBY
               # Sample Ruby code
               def hello(name)
                 puts "Hello, \#{name}!"
               end

               class Greeter
                 GREETING = "Hi"

                 def greet
                   hello("World")
                 end
               end
             RUBY
           when :hcl
             <<~HCL
               # Sample HCL code
               resource "aws_instance" "example" {
                 ami           = "ami-12345678"
                 instance_type = "t2.micro"
                 count         = 3

                 tags = {
                   Name = "HelloWorld"
                 }

                 accounts = [for account in local.accounts : replace(account, "x", "")]
               }
             HCL
           when :python
             <<~PYTHON
               # Sample Python code
               def hello(name):
                   print(f"Hello, {name}!")

               class Greeter:
                   def __init__(self):
                       self.count = 0

                   def greet(self):
                       hello("World")
             PYTHON
           when :javascript
             <<~JS
               // Sample JavaScript code
               function hello(name) {
                 console.log(`Hello, ${name}!`);
               }

               class Greeter {
                 constructor() {
                   this.count = 0;
                 }

                 greet() {
                   hello("World");
                 }
               }
             JS
           else
             puts "No sample code for #{language}. Please provide a file."
             exit 1
           end
         end

  # パース
  parser_path = Textbringer::TreeSitterConfig.parser_path(language)
  ts_language = TreeSitter::Language.load(language.to_s, parser_path)
  parser = TreeSitter::Parser.new
  parser.language = ts_language
  tree = parser.parse_string(nil, code)

  puts "=== Source Code ==="
  puts code
  puts

  # ハイライト情報を収集
  highlights = collect_highlights(tree.root_node, node_map, code)

  puts "=== Highlight Info ==="
  puts "Language: #{language}"
  puts "Total highlights: #{highlights.size}"
  puts

  # ハイライト一覧
  puts "=== Token Details ==="
  highlights.each do |h|
    text = h[:text].gsub("\n", "\\n")
    text = text[0..40] + "..." if text.length > 40
    puts "#{h[:face].to_s.ljust(15)} | #{h[:type].to_s.ljust(20)} | #{text}"
  end

  # カラー出力（単一行トークンのみ）
  print_highlighted_code(code, highlights)
end

main
