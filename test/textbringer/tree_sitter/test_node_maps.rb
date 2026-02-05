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

    assert_equal :function_name, node_map[:method]
    assert_equal :function_name, node_map[:singleton_method]
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

    assert_equal :string, node_map[:string_literal]
    assert_equal :string, node_map[:quoted_template]
  end

  def test_hcl_number_mapping
    node_map = Textbringer::TreeSitter::NodeMaps.for(:hcl)

    assert_equal :number, node_map[:numeric_literal]
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
    # prebuild 済み言語
    assert_includes languages, :bash
    assert_includes languages, :c
    assert_includes languages, :csharp
    assert_includes languages, :cobol
    assert_includes languages, :groovy
    assert_includes languages, :haml
    assert_includes languages, :html
    assert_includes languages, :java
    assert_includes languages, :javascript
    assert_includes languages, :json
    assert_includes languages, :pascal
    assert_includes languages, :php
    assert_includes languages, :python
    assert_includes languages, :rust
    assert_includes languages, :yaml
  end

  # Bash
  def test_bash_basic_mappings
    node_map = Textbringer::TreeSitter::NodeMaps.for(:bash)

    assert_equal :comment, node_map[:comment]
    assert_equal :string, node_map[:string]
    assert_equal :string, node_map[:raw_string]
    assert_equal :keyword, node_map[:if]
    assert_equal :keyword, node_map[:then]
    assert_equal :keyword, node_map[:fi]
    assert_equal :keyword, node_map[:for]
    assert_equal :keyword, node_map[:while]
    assert_equal :keyword, node_map[:do]
    assert_equal :keyword, node_map[:done]
    assert_equal :keyword, node_map[:case]
    assert_equal :keyword, node_map[:esac]
    assert_equal :function_name, node_map[:function_definition]
    assert_equal :variable, node_map[:variable_name]
  end

  # C
  def test_c_basic_mappings
    node_map = Textbringer::TreeSitter::NodeMaps.for(:c)

    assert_equal :comment, node_map[:comment]
    assert_equal :string, node_map[:string_literal]
    assert_equal :string, node_map[:char_literal]
    assert_equal :keyword, node_map[:if]
    assert_equal :keyword, node_map[:else]
    assert_equal :keyword, node_map[:for]
    assert_equal :keyword, node_map[:while]
    assert_equal :keyword, node_map[:return]
    assert_equal :keyword, node_map[:struct]
    assert_equal :keyword, node_map[:typedef]
    assert_equal :number, node_map[:number_literal]
    assert_equal :type, node_map[:primitive_type]
    assert_equal :type, node_map[:type_identifier]
    assert_equal :function_name, node_map[:function_declarator]
  end

  # C#
  def test_csharp_basic_mappings
    node_map = Textbringer::TreeSitter::NodeMaps.for(:csharp)

    assert_equal :comment, node_map[:comment]
    assert_equal :string, node_map[:string_literal]
    assert_equal :keyword, node_map[:if]
    assert_equal :keyword, node_map[:else]
    assert_equal :keyword, node_map[:for]
    assert_equal :keyword, node_map[:while]
    assert_equal :keyword, node_map[:return]
    assert_equal :keyword, node_map[:class]
    assert_equal :keyword, node_map[:namespace]
    assert_equal :keyword, node_map[:using]
    assert_equal :keyword, node_map[:public]
    assert_equal :keyword, node_map[:private]
    assert_equal :number, node_map[:integer_literal]
    assert_equal :type, node_map[:predefined_type]
  end

  # C# alias resolution
  def test_csharp_alias_resolution
    # Test that all these aliases resolve to the same node map
    csharp_map = Textbringer::TreeSitter::NodeMaps.for(:csharp)
    c_sharp_map = Textbringer::TreeSitter::NodeMaps.for(:"c-sharp")
    c_sharp_str = Textbringer::TreeSitter::NodeMaps.for("c-sharp")
    cs_map = Textbringer::TreeSitter::NodeMaps.for(:cs)

    assert_equal csharp_map, c_sharp_map
    assert_equal csharp_map, c_sharp_str
    assert_equal csharp_map, cs_map

    # Verify they all work the same
    assert_equal :keyword, c_sharp_map[:class]
    assert_equal :keyword, cs_map[:class]
  end

  # COBOL
  def test_cobol_basic_mappings
    node_map = Textbringer::TreeSitter::NodeMaps.for(:cobol)

    assert_equal :comment, node_map[:comment]
    assert_equal :string, node_map[:string_literal]
    assert_equal :number, node_map[:number]
    assert_equal :keyword, node_map[:PERFORM]
    assert_equal :keyword, node_map[:IF]
    assert_equal :keyword, node_map[:ELSE]
    assert_equal :keyword, node_map[:END]
    assert_equal :keyword, node_map[:MOVE]
    assert_equal :keyword, node_map[:DISPLAY]
  end

  # Groovy
  def test_groovy_basic_mappings
    node_map = Textbringer::TreeSitter::NodeMaps.for(:groovy)

    assert_equal :comment, node_map[:comment]
    assert_equal :string, node_map[:string]
    assert_equal :keyword, node_map[:if]
    assert_equal :keyword, node_map[:else]
    assert_equal :keyword, node_map[:for]
    assert_equal :keyword, node_map[:while]
    assert_equal :keyword, node_map[:return]
    assert_equal :keyword, node_map[:def]
    assert_equal :keyword, node_map[:class]
    assert_equal :number, node_map[:number_literal]
  end

  # HAML
  def test_haml_basic_mappings
    node_map = Textbringer::TreeSitter::NodeMaps.for(:haml)

    assert_equal :comment, node_map[:comment]
    assert_equal :string, node_map[:string]
    assert_equal :keyword, node_map[:doctype]
    assert_equal :property, node_map[:tag_name]
    assert_equal :property, node_map[:id]
    assert_equal :property, node_map[:class]
  end

  # HTML
  def test_html_basic_mappings
    node_map = Textbringer::TreeSitter::NodeMaps.for(:html)

    assert_equal :comment, node_map[:comment]
    assert_equal :string, node_map[:attribute_value]
    assert_equal :keyword, node_map[:doctype]
    assert_equal :property, node_map[:tag_name]
    assert_equal :property, node_map[:attribute_name]
  end

  # Java
  def test_java_basic_mappings
    node_map = Textbringer::TreeSitter::NodeMaps.for(:java)

    assert_equal :comment, node_map[:comment]
    assert_equal :comment, node_map[:line_comment]
    assert_equal :comment, node_map[:block_comment]
    assert_equal :string, node_map[:string_literal]
    assert_equal :keyword, node_map[:if]
    assert_equal :keyword, node_map[:else]
    assert_equal :keyword, node_map[:for]
    assert_equal :keyword, node_map[:while]
    assert_equal :keyword, node_map[:return]
    assert_equal :keyword, node_map[:class]
    assert_equal :keyword, node_map[:public]
    assert_equal :keyword, node_map[:private]
    assert_equal :keyword, node_map[:static]
    assert_equal :number, node_map[:decimal_integer_literal]
    assert_equal :type, node_map[:type_identifier]
  end

  # JavaScript
  def test_javascript_basic_mappings
    node_map = Textbringer::TreeSitter::NodeMaps.for(:javascript)

    assert_equal :comment, node_map[:comment]
    assert_equal :string, node_map[:string]
    assert_equal :string, node_map[:template_string]
    assert_equal :keyword, node_map[:if]
    assert_equal :keyword, node_map[:else]
    assert_equal :keyword, node_map[:for]
    assert_equal :keyword, node_map[:while]
    assert_equal :keyword, node_map[:return]
    assert_equal :keyword, node_map[:function]
    assert_equal :keyword, node_map[:const]
    assert_equal :keyword, node_map[:let]
    assert_equal :keyword, node_map[:var]
    assert_equal :keyword, node_map[:class]
    assert_equal :keyword, node_map[:import]
    assert_equal :keyword, node_map[:export]
    assert_equal :number, node_map[:number]
    assert_equal :builtin, node_map[:true]
    assert_equal :builtin, node_map[:false]
    assert_equal :builtin, node_map[:null]
    assert_equal :builtin, node_map[:undefined]
  end

  # JavaScript alias resolution
  def test_javascript_alias_resolution
    javascript_map = Textbringer::TreeSitter::NodeMaps.for(:javascript)
    js_map = Textbringer::TreeSitter::NodeMaps.for(:js)

    assert_equal javascript_map, js_map
  end

  # JSON
  def test_json_basic_mappings
    node_map = Textbringer::TreeSitter::NodeMaps.for(:json)

    assert_equal :string, node_map[:string]
    assert_equal :number, node_map[:number]
    assert_equal :builtin, node_map[:true]
    assert_equal :builtin, node_map[:false]
    assert_equal :builtin, node_map[:null]
    assert_equal :property, node_map[:pair]
  end

  # Pascal
  def test_pascal_basic_mappings
    node_map = Textbringer::TreeSitter::NodeMaps.for(:pascal)

    assert_equal :comment, node_map[:comment]
    assert_equal :string, node_map[:string]
    assert_equal :keyword, node_map[:kBegin]
    assert_equal :keyword, node_map[:kEnd]
    assert_equal :keyword, node_map[:kIf]
    assert_equal :keyword, node_map[:kThen]
    assert_equal :keyword, node_map[:kElse]
    assert_equal :keyword, node_map[:kFor]
    assert_equal :keyword, node_map[:kWhile]
    assert_equal :keyword, node_map[:kFunction]
    assert_equal :keyword, node_map[:kProcedure]
    assert_equal :keyword, node_map[:kVar]
    assert_equal :number, node_map[:integer]
    assert_equal :number, node_map[:real]
  end

  # PHP
  def test_php_basic_mappings
    node_map = Textbringer::TreeSitter::NodeMaps.for(:php)

    assert_equal :comment, node_map[:comment]
    assert_equal :string, node_map[:string]
    assert_equal :string, node_map[:encapsed_string]
    assert_equal :keyword, node_map[:if]
    assert_equal :keyword, node_map[:else]
    assert_equal :keyword, node_map[:for]
    assert_equal :keyword, node_map[:foreach]
    assert_equal :keyword, node_map[:while]
    assert_equal :keyword, node_map[:return]
    assert_equal :keyword, node_map[:function]
    assert_equal :keyword, node_map[:class]
    assert_equal :keyword, node_map[:public]
    assert_equal :keyword, node_map[:private]
    assert_equal :keyword, node_map[:namespace]
    assert_equal :keyword, node_map[:use]
    assert_equal :number, node_map[:integer]
    assert_equal :number, node_map[:float]
    assert_equal :variable, node_map[:variable_name]
  end

  # Python
  def test_python_basic_mappings
    node_map = Textbringer::TreeSitter::NodeMaps.for(:python)

    assert_equal :comment, node_map[:comment]
    assert_equal :string, node_map[:string]
    assert_equal :keyword, node_map[:if]
    assert_equal :keyword, node_map[:elif]
    assert_equal :keyword, node_map[:else]
    assert_equal :keyword, node_map[:for]
    assert_equal :keyword, node_map[:while]
    assert_equal :keyword, node_map[:return]
    assert_equal :keyword, node_map[:def]
    assert_equal :keyword, node_map[:class]
    assert_equal :keyword, node_map[:import]
    assert_equal :keyword, node_map[:from]
    assert_equal :keyword, node_map[:as]
    assert_equal :keyword, node_map[:with]
    assert_equal :keyword, node_map[:try]
    assert_equal :keyword, node_map[:except]
    assert_equal :keyword, node_map[:finally]
    assert_equal :number, node_map[:integer]
    assert_equal :number, node_map[:float]
    assert_equal :builtin, node_map[:true]
    assert_equal :builtin, node_map[:false]
    assert_equal :builtin, node_map[:none]
  end

  # Rust
  def test_rust_basic_mappings
    node_map = Textbringer::TreeSitter::NodeMaps.for(:rust)

    assert_equal :comment, node_map[:line_comment]
    assert_equal :comment, node_map[:block_comment]
    assert_equal :string, node_map[:string_literal]
    assert_equal :string, node_map[:char_literal]
    assert_equal :keyword, node_map[:if]
    assert_equal :keyword, node_map[:else]
    assert_equal :keyword, node_map[:for]
    assert_equal :keyword, node_map[:while]
    assert_equal :keyword, node_map[:loop]
    assert_equal :keyword, node_map[:return]
    assert_equal :keyword, node_map[:fn]
    assert_equal :keyword, node_map[:let]
    assert_equal :keyword, node_map[:mut]
    assert_equal :keyword, node_map[:struct]
    assert_equal :keyword, node_map[:enum]
    assert_equal :keyword, node_map[:impl]
    assert_equal :keyword, node_map[:trait]
    assert_equal :keyword, node_map[:pub]
    assert_equal :keyword, node_map[:mod]
    assert_equal :keyword, node_map[:use]
    assert_equal :number, node_map[:integer_literal]
    assert_equal :number, node_map[:float_literal]
    assert_equal :type, node_map[:type_identifier]
    assert_equal :type, node_map[:primitive_type]
    assert_equal :builtin, node_map[:true]
    assert_equal :builtin, node_map[:false]
  end

  # YAML
  def test_yaml_basic_mappings
    node_map = Textbringer::TreeSitter::NodeMaps.for(:yaml)

    assert_equal :comment, node_map[:comment]
    assert_equal :string, node_map[:string_scalar]
    assert_equal :string, node_map[:double_quote_scalar]
    assert_equal :string, node_map[:single_quote_scalar]
    assert_equal :number, node_map[:integer_scalar]
    assert_equal :number, node_map[:float_scalar]
    assert_equal :builtin, node_map[:boolean_scalar]
    assert_equal :builtin, node_map[:null_scalar]
    assert_equal :property, node_map[:block_mapping_pair]
    assert_equal :keyword, node_map[:anchor]
    assert_equal :keyword, node_map[:alias]
  end
end
