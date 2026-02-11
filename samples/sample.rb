# frozen_string_literal: true

# Single line comment

=begin
Multi-line
comment block
=end

# --- Keywords ---
module SampleModule
  class SampleClass
    def initialize(name)
      @name = name
    end

    def greet
      if @name
        puts "Hello, #{@name}!"
      elsif @name.nil?
        puts "No name"
      else
        puts "Unknown"
      end

      unless @name.empty?
        yield self if block_given?
      end

      case @name
      when "Alice" then "A"
      when "Bob"   then "B"
      else              "?"
      end
    end

    def self.singleton_example
      super
    end
  end
end

# --- Loops ---
i = 0
while i < 10
  break if i == 5
  next if i == 3
  i += 1
end

until i <= 0
  i -= 1
  redo if false
end

for x in [1, 2, 3]
  puts x
end

10.times do |n|
  retry if false
end

# --- Strings ---
single = 'single quoted'
double = "double quoted with #{1 + 2} interpolation"
heredoc = <<~HEREDOC
  This is a heredoc
  with multiple lines
HEREDOC
heredoc_squiggly = <<~'SQUIGGLY'
  No interpolation here
SQUIGGLY
bare_string = %q(bare string)
regex_literal = /pattern[a-z]+/i
escaped = "tab\tnewline\n"
char = ?a
subshell = `echo hello`
chained = "hello" \
          "world"
symbol = :simple_symbol
fancy_symbol = :"delimited symbol"
symbol_array = %i[foo bar baz]
string_array = %w[hello world]

# --- Numbers ---
integer_val = 42
negative = -17
hex = 0xFF
octal = 0o77
binary = 0b1010
float_val = 3.14
scientific = 1.5e10
complex_val = 1i
rational_val = 3/4r

# --- Constants & Builtins ---
PI = 3.14159
CONST_VAL = true
nothing = nil
falsy = false

# --- Variables ---
local_var = "local"
@instance_var = "instance"
@@class_var = "class"
$global_var = "global"

# --- Operators ---
sum = 1 + 2
diff = 5 - 3
prod = 4 * 2
quot = 10 / 3
modulo = 10 % 3
power = 2 ** 8
comparison = (1 <=> 2)
logical = true && false || !nil
bitwise = 0xFF & 0x0F | 0x10 ^ 0x01
shift = 1 << 4
range = (1..10)
exclusive_range = (1...10)
ternary = true ? "yes" : "no"

# --- Method definitions ---
def standalone_method(a, b = 10, *args, key:, **opts, &block)
  return a + b
end

# --- Exception handling ---
begin
  raise StandardError, "oops"
rescue StandardError => e
  puts e.message
ensure
  puts "cleanup"
end

# --- Special keywords ---
alias new_method greet
defined?(local_var)
self
BEGIN { puts "begin block" }
END { puts "end block" }

# --- Lambda / Proc ---
my_lambda = lambda { |x| x * 2 }
my_proc = ->(x) { x + 1 }

# --- Pattern matching (Ruby 3.x) ---
case [1, 2, 3]
in [Integer => a, Integer => b, *]
  puts a + b
in { name: String => name }
  puts name
end

# --- Encoding constants ---
enc = __ENCODING__
file = __FILE__
line = __LINE__
