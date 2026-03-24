# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "minitest/autorun"
require "fileutils"
require "tmpdir"

# Textbringer mock implementation (no real gem dependency)
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
    attr_accessor :buffer

    def initialize(buffer = nil)
      @buffer = buffer
    end

    def highlight(ctx)
      # default no-op
    end
  end

  class HighlightContext
    attr_reader :buffer, :highlight_start, :highlight_end,
                :highlight_on, :highlight_off

    def initialize(buffer:, highlight_start:, highlight_end:,
                   highlight_on:, highlight_off:)
      @buffer = buffer
      @highlight_start = highlight_start
      @highlight_end = highlight_end
      @highlight_on = highlight_on
      @highlight_off = highlight_off
    end

    def highlight(start_offset, end_offset, face)
      start_offset = @highlight_start if start_offset < @highlight_start &&
        @highlight_start < end_offset
      @highlight_on[start_offset] = face
      @highlight_off[end_offset] = true
    end
  end

  class Window
    @@has_colors = true

    attr_reader :buffer

    def initialize(buffer = nil)
      @buffer = buffer || MockBuffer.new
      @highlight_on = {}
      @highlight_off = {}
    end

    def highlight
      @highlight_on = {}
      @highlight_off = {}
      return unless @@has_colors
      ctx = HighlightContext.new(
        buffer: @buffer,
        highlight_start: 0,
        highlight_end: @buffer.to_s.bytesize,
        highlight_on: @highlight_on,
        highlight_off: @highlight_off
      )
      @buffer.mode.highlight(ctx) if @buffer.mode
    end

    def highlight_on
      @highlight_on
    end

    def highlight_off
      @highlight_off
    end

    def self.has_colors=(value)
      @@has_colors = value
    end

    def self.has_colors
      @@has_colors
    end
  end

  class MockBuffer
    attr_reader :mode
    attr_accessor :file_name

    def mode=(m)
      @mode = m
      m.buffer = self if m.respond_to?(:buffer=)
    end

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
