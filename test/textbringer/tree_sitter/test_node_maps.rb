# frozen_string_literal: true

require "test_helper"
require "textbringer/tree_sitter/node_maps"

class NodeMapsTest < Minitest::Test
  def setup
    Textbringer::TreeSitter::NodeMaps.clear_custom_maps
  end

  def test_ruby_keyword_mappings
    node_map = Textbringer::TreeSitter::NodeMaps.for(:ruby)

    # 基本キーワード
    assert_equal :keyword, node_map[:def]
    assert_equal :keyword, node_map[:end]
    assert_equal :keyword, node_map[:class]
    assert_equal :keyword, node_map[:module]
    assert_equal :keyword, node_map[:if]
    assert_equal :keyword, node_map[:else]
    assert_equal :keyword, node_map[:unless]
    assert_equal :keyword, node_map[:while]
    assert_equal :keyword, node_map[:do]
    assert_equal :keyword, node_map[:begin]
    assert_equal :keyword, node_map[:rescue]
    assert_equal :keyword, node_map[:ensure]
    assert_equal :keyword, node_map[:return]
    assert_equal :keyword, node_map[:yield]
  end

  def test_ruby_string_mappings
    node_map = Textbringer::TreeSitter::NodeMaps.for(:ruby)

    assert_equal :string, node_map[:string_content]
    assert_equal :string, node_map[:heredoc_content]
    assert_equal :string, node_map[:simple_symbol]
    assert_equal :string, node_map[:escape_sequence]
  end

  def test_ruby_comment_mapping
    node_map = Textbringer::TreeSitter::NodeMaps.for(:ruby)

    assert_equal :comment, node_map[:comment]
  end

  def test_ruby_number_mappings
    node_map = Textbringer::TreeSitter::NodeMaps.for(:ruby)

    assert_equal :number, node_map[:integer]
    assert_equal :number, node_map[:float]
    assert_equal :number, node_map[:complex]
    assert_equal :number, node_map[:rational]
  end

  def test_ruby_constant_mapping
    node_map = Textbringer::TreeSitter::NodeMaps.for(:ruby)

    assert_equal :constant, node_map[:constant]
  end

  def test_ruby_function_name_mapping
    node_map = Textbringer::TreeSitter::NodeMaps.for(:ruby)

    assert_equal :function_name, node_map[:method_name]
  end

  def test_ruby_features_structure
    features = Textbringer::TreeSitter::NodeMaps::RUBY_FEATURES

    assert features.key?(:comment)
    assert features.key?(:string)
    assert features.key?(:keyword)
    assert features.key?(:number)
    assert features.key?(:constant)
    assert features.key?(:function_name)

    assert features[:comment].include?(:comment)
    assert features[:keyword].include?(:def)
    assert features[:string].include?(:string_content)
  end

  def test_hcl_keyword_mappings
    node_map = Textbringer::TreeSitter::NodeMaps.for(:hcl)

    # Rouge で認識されなかった for, in がキーワードとして認識される
    assert_equal :keyword, node_map[:for]
    assert_equal :keyword, node_map[:in]
    assert_equal :keyword, node_map[:if]
    assert_equal :keyword, node_map[:else]
    assert_equal :keyword, node_map[:true]
    assert_equal :keyword, node_map[:false]
    assert_equal :keyword, node_map[:null]
  end

  def test_hcl_function_call_mapping
    node_map = Textbringer::TreeSitter::NodeMaps.for(:hcl)

    # Rouge で認識されなかった function_call
    assert_equal :function_name, node_map[:function_call]
  end

  def test_hcl_string_mapping
    node_map = Textbringer::TreeSitter::NodeMaps.for(:hcl)

    assert_equal :string, node_map[:string_lit]
    assert_equal :string, node_map[:quoted_template]
  end

  def test_hcl_number_mapping
    node_map = Textbringer::TreeSitter::NodeMaps.for(:hcl)

    assert_equal :number, node_map[:numeric_lit]
  end

  def test_hcl_comment_mapping
    node_map = Textbringer::TreeSitter::NodeMaps.for(:hcl)

    assert_equal :comment, node_map[:comment]
  end

  def test_hcl_features_structure
    features = Textbringer::TreeSitter::NodeMaps::HCL_FEATURES

    assert features.key?(:comment)
    assert features.key?(:string)
    assert features.key?(:keyword)
    assert features.key?(:number)
    assert features.key?(:function_name)
  end

  def test_custom_mapping_registration
    custom_map = { custom_node: :keyword }

    Textbringer::TreeSitter::NodeMaps.register(:custom_lang, custom_map)

    node_map = Textbringer::TreeSitter::NodeMaps.for(:custom_lang)
    assert_equal :keyword, node_map[:custom_node]
  end

  def test_custom_mapping_overrides_default
    original_map = Textbringer::TreeSitter::NodeMaps.for(:ruby)
    assert_equal :keyword, original_map[:def]

    # カスタムマップで上書き
    custom_ruby = { def: :constant }
    Textbringer::TreeSitter::NodeMaps.register(:ruby, custom_ruby)

    node_map = Textbringer::TreeSitter::NodeMaps.for(:ruby)
    assert_equal :constant, node_map[:def]

    # 他のノードはデフォルトを継承
    assert_equal :comment, node_map[:comment]
  end

  def test_for_returns_nil_for_unknown_language_without_custom_map
    node_map = Textbringer::TreeSitter::NodeMaps.for(:unknown_language)
    assert_nil node_map
  end

  def test_available_languages
    languages = Textbringer::TreeSitter::NodeMaps.available_languages

    assert_includes languages, :ruby
    assert_includes languages, :hcl
  end
end
