# frozen_string_literal: true

require "test_helper"
require "textbringer/tree_sitter/injection_maps"

class InjectionMapsEmbeddedTemplateTest < Minitest::Test
  def entries
    Textbringer::TreeSitter::InjectionMaps.for(:"embedded-template")
  end

  def test_registers_embedded_template_injections
    refute_nil entries
  end

  def test_directive_injects_ruby
    entry = entries.find { |e| e[:node_type] == :directive }
    assert_equal :code, entry[:content]
    assert_equal :ruby, entry[:language]
  end

  def test_output_directive_injects_ruby
    entry = entries.find { |e| e[:node_type] == :output_directive }
    assert_equal :code, entry[:content]
    assert_equal :ruby, entry[:language]
  end

  def test_content_self_injects_html
    entry = entries.find { |e| e[:node_type] == :content }
    assert_equal :content, entry[:content]
    assert_equal :html, entry[:language]
  end
end
