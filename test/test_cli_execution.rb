# frozen_string_literal: true

require "minitest/autorun"
require "open3"

class TestCLIExecution < Minitest::Test
  def test_help_via_bundle_exec
    out, err, status = Open3.capture3("bundle", "exec", "textbringer-tree-sitter", "help")
    assert status.success?, "CLI should exit successfully, stderr: #{err}"
    assert_match(/Usage:/, out, "CLI should display usage information")
  end

  def test_path_via_bundle_exec
    out, err, status = Open3.capture3("bundle", "exec", "textbringer-tree-sitter", "path")
    assert status.success?, "CLI should exit successfully, stderr: #{err}"
    assert_match(/parsers/, out, "CLI should display parser directory path")
  end

  def test_no_args_shows_help_via_bundle_exec
    out, err, status = Open3.capture3("bundle", "exec", "textbringer-tree-sitter")
    assert status.success?, "CLI should exit successfully, stderr: #{err}"
    assert_match(/Usage:/, out, "CLI should display usage information when no args")
  end
end
