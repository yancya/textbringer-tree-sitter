# frozen_string_literal: true

require_relative "lib/textbringer/tree_sitter/version"

Gem::Specification.new do |spec|
  spec.name = "textbringer-tree-sitter"
  spec.version = Textbringer::TreeSitter::VERSION
  spec.authors = ["yancya"]
  spec.email = ["yancya@gmail.com"]

  spec.summary = "Tree-sitter based syntax highlighting for Textbringer"
  spec.description = "Provides accurate syntax highlighting using Tree-sitter parsers for Textbringer editor"
  spec.homepage = "https://github.com/yancya/textbringer-tree-sitter"
  spec.license = "WTFPL"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.require_paths = ["lib"]
  spec.extensions = ["ext/textbringer_tree_sitter/extconf.rb"]
  spec.bindir = "exe"
  spec.executables = ["textbringer-tree-sitter"]

  spec.add_dependency "textbringer", ">= 1.0"
  spec.add_dependency "ruby_tree_sitter", "~> 2.0"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
