#!/usr/bin/env ruby
# frozen_string_literal: true

# Appends heuristic node-map suggestions (all commented out) for newly
# detected upstream node types, so a human can review before enabling any
# of them. See lib/textbringer/tree_sitter/node_maps/*.rb for the format
# these suggestions are meant to be promoted into.

def guess_face(node_name)
  name = node_name.to_s.downcase
  case name
  when /comment/
    :comment
  when /string|heredoc|char_literal|template_string/
    :string
  when /number|integer|float|decimal|numeric/
    :number
  when /\b(if|else|elsif|unless|case|when|while|until|for|do|end|begin|rescue|ensure|return|yield|break|next|redo|retry|raise|class|module|def|alias|defined|super|self|nil|true|false|and|or|not|in|fn|func|function|let|const|var|import|export|from|as|try|catch|finally|throw|async|await|match|loop|struct|enum|impl|trait|pub|mut|ref|use|mod|crate|where|type|interface|package|extends|implements|static|final|abstract|native|synchronized|volatile|transient|new|this|instanceof|goto|switch|default|continue|assert|with|pass|lambda|nonlocal|global|del|except|exec|print|elif|is)\b/
    :keyword
  when /keyword|reserved/
    :keyword
  when /constant|boolean/
    :constant
  when /function_name|method_name|call|invocation/
    :function_name
  when /type|class_name|struct_name|interface_name/
    :type
  when /variable|identifier|name/
    :variable
  when /operator|binary_op|unary_op/
    :operator
  when /punctuation|delimiter|bracket|paren|brace/
    :punctuation
  when /marker|heading|header/
    :keyword
  else
    nil
  end
end

language = ARGV[0]
release = ARGV[1]
new_nodes = ARGV[2..] || []

if language.nil? || release.nil?
  warn "Usage: append_node_map_suggestions.rb <language> <release> <node_type>..."
  exit 1
end

node_map_file = "lib/textbringer/tree_sitter/node_maps/#{language}.rb"

unless File.exist?(node_map_file)
  warn "Error: node map not found: #{node_map_file}"
  exit 1
end

content = File.read(node_map_file)
marker = "# NEW in #{release}"

if content.include?(marker)
  # Already appended for this release -- avoid duplicating on re-run.
  exit 0
end

section = +"\n#{marker} (auto-suggested, review before enabling):\n"
new_nodes.each do |node|
  face = guess_face(node)
  if face
    section << "#   #{node} => :#{face}\n"
  else
    section << "#   #{node} (unmapped)\n"
  end
end

File.write(node_map_file, content + section)
puts "Appended #{new_nodes.size} suggestion(s) to #{node_map_file}"
