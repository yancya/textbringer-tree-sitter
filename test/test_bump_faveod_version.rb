# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "fileutils"
require "tmpdir"

class TestBumpFaveodVersion < Minitest::Test
  SCRIPT = File.expand_path("../scripts/bump_faveod_version.sh", __dir__)
  TARGET_FILES = %w[
    .github/workflows/sync-upstream.yml
    ext/textbringer_tree_sitter/extconf.rb
    scripts/build_parsers.sh
    scripts/download_parsers.sh
  ].freeze

  def setup
    @dir = Dir.mktmpdir
    TARGET_FILES.each do |relative|
      dest = File.join(@dir, relative)
      FileUtils.mkdir_p(File.dirname(dest))
      FileUtils.cp(File.expand_path("../#{relative}", __dir__), dest)
    end
    FileUtils.cp(SCRIPT, File.join(@dir, "bump_faveod_version.sh"))
  end

  def teardown
    FileUtils.remove_entry(@dir)
  end

  def run_bump(version)
    Open3.capture3("bash", "bump_faveod_version.sh", version, chdir: @dir)
  end

  def test_rewrites_all_four_files
    _out, err, status = run_bump("v5.6")
    assert status.success?, "script should exit successfully, stderr: #{err}"

    TARGET_FILES.each do |relative|
      content = File.read(File.join(@dir, relative))
      refute_match(/v5\.5/, content, "#{relative} should no longer reference the old version")
      assert_match(/v5\.6/, content, "#{relative} should reference the new version")
    end
  end

  def test_rejects_malformed_version
    _out, err, status = run_bump("5.6")
    refute status.success?, "script should reject a version without a leading v"
    assert_match(/version/i, err)
  end

  def test_idempotent_when_rerun_with_same_version
    run_bump("v5.6")
    _out, err, status = run_bump("v5.6")
    assert status.success?, "re-running with the same version should not fail, stderr: #{err}"

    TARGET_FILES.each do |relative|
      content = File.read(File.join(@dir, relative))
      assert_match(/v5\.6/, content)
    end
  end
end
