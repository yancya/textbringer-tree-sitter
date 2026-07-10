# frozen_string_literal: true

require "test_helper"
require "textbringer/tree_sitter/node_maps"

class NodeMapsEmbeddedTemplateTest < Minitest::Test
  def node_map
    Textbringer::TreeSitter::NodeMaps.for(:"embedded-template")
  end

  def test_delimiters_mapped_to_keyword
    assert_equal :keyword, node_map[:"<%"]
    assert_equal :keyword, node_map[:"%>"]
    assert_equal :keyword, node_map[:"<%="]
  end

  def test_comment_mapped
    assert_equal :comment, node_map[:comment]
  end

  def test_code_and_content_left_unmapped_for_injection
    # Highlighted via language injection instead (injection_maps/embedded_template.rb)
    assert_nil node_map[:code]
    assert_nil node_map[:content]
  end
end
