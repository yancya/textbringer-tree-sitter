# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "minitest/autorun"
require "fileutils"
require "tmpdir"

# Textbringer モック実装（実 gem 依存なし）
module Textbringer
  CONFIG = {}

  class Face
    @faces = {}

    class << self
      def [](name)
        @faces[name]
      end

      def define(name, **attrs)
        @faces[name] = new(name, attrs)
      end

      def clear_all
        @faces.clear
      end
    end

    attr_reader :name, :attributes

    def initialize(name, attributes)
      @name = name
      @attributes = attributes
    end
  end

  class Mode
  end

  class Window
    attr_accessor :highlight_on, :highlight_off
    attr_reader :buffer

    def initialize(buffer = nil)
      @buffer = buffer || MockBuffer.new
      @highlight_on = {}
      @highlight_off = {}
    end

    def highlight
      # original highlight (no-op for tests)
    end
  end

  class MockBuffer
    attr_accessor :mode, :file_name

    def initialize
      @mode = nil
      @file_name = nil
      @content = ""
    end

    def to_s
      @content
    end

    def content=(str)
      @content = str
    end

    def point_min
      0
    end
  end
end

require "textbringer/tree_sitter/version"
