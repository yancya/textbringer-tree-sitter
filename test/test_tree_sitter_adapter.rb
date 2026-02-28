# frozen_string_literal: true

require_relative "test_helper"
require "textbringer/tree_sitter_adapter"

class TestTreeSitterAdapter < Minitest::Test
  def setup
    Textbringer::Face.clear_all
    Textbringer::CONFIG.clear

    # Define basic test mode
    @test_mode_class = Class.new(Textbringer::Mode)
    @test_mode_class.extend(Textbringer::TreeSitterAdapter::ClassMethods)
  end

  def test_use_tree_sitter_enables_by_default
    @test_mode_class.use_tree_sitter(:ruby)

    mode = @test_mode_class.new
    assert_equal :ruby, mode.tree_sitter_language
    assert @test_mode_class.tree_sitter_enabled?
  end

  def test_tree_sitter_enabled_setter_disables_highlight
    @test_mode_class.use_tree_sitter(:ruby)
    @test_mode_class.tree_sitter_enabled = false

    refute @test_mode_class.tree_sitter_enabled?
  end

  def test_tree_sitter_enabled_setter_can_re_enable
    @test_mode_class.use_tree_sitter(:ruby)
    @test_mode_class.tree_sitter_enabled = false
    @test_mode_class.tree_sitter_enabled = true

    assert @test_mode_class.tree_sitter_enabled?
  end

  def test_window_highlight_uses_original_when_disabled
    @test_mode_class.use_tree_sitter(:ruby)
    @test_mode_class.tree_sitter_enabled = false

    mode = @test_mode_class.new
    buffer = Textbringer::MockBuffer.new
    buffer.content = "def hello\nend"
    buffer.mode = mode

    window = Textbringer::Window.new(buffer)

    # Window#highlight should call original_highlight when disabled
    window.highlight

    # highlight_on/off should be empty (original_highlight was called)
    assert_empty window.instance_variable_get(:@highlight_on)
    assert_empty window.instance_variable_get(:@highlight_off)
  end
end
