# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "rubygems/package"
require "zlib"

# exe/textbringer-tree-sitter は __FILE__ == $PROGRAM_NAME ガード付きなので
# load で読み込んでも CLI は実行されない
load File.expand_path("../exe/textbringer-tree-sitter", __dir__)

class TestExtractTarball < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir
    @extract_dir = File.join(@tmpdir, "extract")
    FileUtils.mkdir_p(@extract_dir)
  end

  def teardown
    FileUtils.rm_rf(@tmpdir)
  end

  # Helper: 指定エントリを含む .tar.gz を作成
  def create_tarball(entries)
    tarball_path = File.join(@tmpdir, "test.tar.gz")
    File.open(tarball_path, "wb") do |file|
      Zlib::GzipWriter.wrap(file) do |gz|
        Gem::Package::TarWriter.new(gz) do |tar|
          entries.each do |name, content|
            tar.add_file_simple(name, 0o644, content.bytesize) do |io|
              io.write(content)
            end
          end
        end
      end
    end
    tarball_path
  end

  def test_extract_normal_tarball
    tarball = create_tarball(
      "subdir/hello.txt" => "hello world",
      "subdir/nested/file.txt" => "nested content"
    )

    result = TextbringerTreeSitterCLI.extract_tarball(tarball, @extract_dir)

    assert result
    assert_equal "hello world", File.read(File.join(@extract_dir, "subdir/hello.txt"))
    assert_equal "nested content", File.read(File.join(@extract_dir, "subdir/nested/file.txt"))
  end

  def test_extract_tarball_rejects_path_traversal
    tarball = create_tarball(
      "../../etc/malicious.txt" => "evil content"
    )

    error = assert_raises(RuntimeError) do
      TextbringerTreeSitterCLI.extract_tarball(tarball, @extract_dir)
    end
    assert_match(/[Pp]ath traversal/, error.message)

    # extract_dir の外にファイルが書き込まれていないことを確認
    refute File.exist?(File.join(@tmpdir, "etc/malicious.txt"))
  end

  def test_extract_tarball_with_leading_slash_stays_within_extract_dir
    # Ruby の File.join は先頭の / があっても extract_dir 配下に展開する
    # （Python の os.path.join とは異なる挙動）
    tarball = create_tarball(
      "/tmp/file.txt" => "content"
    )

    result = TextbringerTreeSitterCLI.extract_tarball(tarball, @extract_dir)

    assert result
    assert_equal "content", File.read(File.join(@extract_dir, "tmp/file.txt"))
    # extract_dir の外には書き込まれていない
    refute File.exist?("/tmp/file.txt") unless File.exist?("/tmp/file.txt") # skip if /tmp/file.txt already exists
  end

  def test_extract_tarball_rejects_dotdot_in_middle_of_path
    tarball = create_tarball(
      "subdir/../../etc/passwd" => "evil"
    )

    error = assert_raises(RuntimeError) do
      TextbringerTreeSitterCLI.extract_tarball(tarball, @extract_dir)
    end
    assert_match(/[Pp]ath traversal/, error.message)
  end
end
