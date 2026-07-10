# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "fileutils"
require "tmpdir"

class TestAppendNodeMapSuggestions < Minitest::Test
  SCRIPT = File.expand_path("../scripts/append_node_map_suggestions.rb", __dir__)

  def setup
    @dir = Dir.mktmpdir
    FileUtils.mkdir_p(File.join(@dir, "lib/textbringer/tree_sitter/node_maps"))
    File.write(File.join(@dir, "lib/textbringer/tree_sitter/node_maps/ruby.rb"), <<~RUBY)
      # frozen_string_literal: true

      module Textbringer
        module TreeSitter
          module NodeMaps
            RUBY_FEATURES = {
              keyword: %i[def end],
            }.freeze

            RUBY = RUBY_FEATURES.flat_map { |face, nodes|
              nodes.map { |node| [node, face] }
            }.to_h.freeze
          end
        end
      end
    RUBY
  end

  def teardown
    FileUtils.remove_entry(@dir)
  end

  def run_script(*args)
    Open3.capture3("ruby", SCRIPT, *args, chdir: @dir)
  end

  def node_map_content
    File.read(File.join(@dir, "lib/textbringer/tree_sitter/node_maps/ruby.rb"))
  end

  def test_appends_commented_suggestions_for_new_nodes
    _out, err, status = run_script("ruby", "v27", "new_string_literal", "new_keyword_thing")
    assert status.success?, "script should exit successfully, stderr: #{err}"

    content = node_map_content
    assert_match(/# NEW in v27/, content)
    assert_match(/#\s*new_string_literal.*:string/, content)
    assert_match(/#\s*new_keyword_thing.*:keyword/, content)
  end

  def test_all_suggested_entries_are_commented_out
    run_script("ruby", "v27", "new_string_literal", "totally_unguessable_xyz")

    content = node_map_content
    marker_index = content.index("# NEW in v27")
    new_section = content[marker_index..]
    new_section.lines.each do |line|
      next if line.strip.empty?

      assert_match(/\A\s*#/, line, "expected every suggestion line to be commented out: #{line.inspect}")
    end
  end

  def test_unguessable_node_marked_as_unmapped
    run_script("ruby", "v27", "totally_unguessable_xyz")

    content = node_map_content
    assert_match(/totally_unguessable_xyz.*unmapped/, content)
  end

  def test_does_not_modify_existing_mapped_entries
    original = node_map_content
    run_script("ruby", "v27", "new_string_literal")

    content = node_map_content
    assert_includes content, "keyword: %i[def end]"
    refute_equal original, content
  end

  def test_missing_node_map_file_errors_without_crashing
    _out, err, status = run_script("nonexistent_lang", "v27", "some_node")
    refute status.success?
    assert_match(/not found|no such/i, err)
  end

  def test_rerun_does_not_duplicate_the_same_release_section
    run_script("ruby", "v27", "new_string_literal")
    run_script("ruby", "v27", "new_string_literal")

    content = node_map_content
    assert_equal 1, content.scan("# NEW in v27").size
  end
end
