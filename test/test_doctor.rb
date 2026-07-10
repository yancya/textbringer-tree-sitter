# frozen_string_literal: true

require_relative "test_helper"

# Load the CLI module
load File.expand_path("../exe/textbringer-tree-sitter", __dir__)

class TestDoctor < Minitest::Test
  CLI = TextbringerTreeSitterCLI

  def setup
    @temp_home = Dir.mktmpdir
    @original_home = ENV["HOME"]
    ENV["HOME"] = @temp_home
  end

  def teardown
    ENV["HOME"] = @original_home
    FileUtils.rm_rf(@temp_home) if @temp_home && File.exist?(@temp_home)
  end

  def test_runs_without_crashing_with_no_parsers_installed
    report = CLI.doctor_report(check_upstream: false)
    assert_kind_of String, report
    assert_match(/Platform/, report)
    assert_match(/Parser directory/, report)
  end

  def test_reports_parser_directory
    report = CLI.doctor_report(check_upstream: false)
    assert_match(/#{Regexp.escape(CLI.parser_dir)}/, report)
  end

  def test_reports_installed_parser_with_size_and_mtime
    FileUtils.mkdir_p(CLI.parser_dir)
    dummy = File.join(CLI.parser_dir, "libtree-sitter-ruby#{CLI.dylib_ext}")
    File.write(dummy, "not a real parser, just bytes")

    report = CLI.doctor_report(check_upstream: false)
    assert_match(/ruby/, report)
    assert_match(/bytes|KB|B\b/, report)
  end

  def test_reports_unloadable_parser_as_warning
    FileUtils.mkdir_p(CLI.parser_dir)
    dummy = File.join(CLI.parser_dir, "libtree-sitter-ruby#{CLI.dylib_ext}")
    File.write(dummy, "not a real shared library")

    report = CLI.doctor_report(check_upstream: false)
    assert_match(/warning|fail|error/i, report)
  end

  def test_reports_missing_node_map_for_language_without_default_map
    FileUtils.mkdir_p(CLI.parser_dir)
    dummy = File.join(CLI.parser_dir, "libtree-sitter-zig#{CLI.dylib_ext}")
    File.write(dummy, "not a real parser")

    report = CLI.doctor_report(check_upstream: false)
    assert_match(/zig/, report)
    assert_match(/no node map|missing node map/i, report)
  end

  def test_reports_checksum_status
    FileUtils.mkdir_p(CLI.parser_dir)
    dummy = File.join(CLI.parser_dir, "libtree-sitter-ruby#{CLI.dylib_ext}")
    File.write(dummy, "content")
    CLI.save_checksums({ "https://example.com/tarball.tar.gz" => "deadbeef" })

    report = CLI.doctor_report(check_upstream: false)
    assert_match(/checksum/i, report)
  end

  def test_does_not_crash_on_non_string_checksum_value
    CLI.save_checksums({ "https://example.com/tarball.tar.gz" => 12_345 })

    report = CLI.doctor_report(check_upstream: false)
    assert_match(/12345|12_345/, report)
  end

  def test_does_not_crash_on_malformed_checksums_json
    FileUtils.mkdir_p(File.dirname(CLI.checksums_file))
    File.write(CLI.checksums_file, "{ not valid json")

    report = CLI.doctor_report(check_upstream: false)
    assert_match(/none recorded/i, report)
  end

  def test_skips_network_check_when_disabled
    report = CLI.doctor_report(check_upstream: false)
    refute_match(/latest.*release/i, report)
  end

  def test_exit_code_zero_by_default_even_with_problems
    FileUtils.mkdir_p(CLI.parser_dir)
    dummy = File.join(CLI.parser_dir, "libtree-sitter-ruby#{CLI.dylib_ext}")
    File.write(dummy, "broken")

    assert_equal true, CLI.doctor(strict: false, check_upstream: false)
  end

  def test_exit_code_nonzero_in_strict_mode_with_problems
    FileUtils.mkdir_p(CLI.parser_dir)
    dummy = File.join(CLI.parser_dir, "libtree-sitter-ruby#{CLI.dylib_ext}")
    File.write(dummy, "broken")

    assert_equal false, CLI.doctor(strict: true, check_upstream: false)
  end

  def test_exit_code_true_in_strict_mode_with_no_problems
    assert_equal true, CLI.doctor(strict: true, check_upstream: false)
  end
end
