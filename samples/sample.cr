# Single line comment

# Crystal sample - Ruby-like syntax with static typing

# --- Require ---
require "json"
require "http/client"

# --- Constants ---
MAX_SIZE = 100
PI       = 3.14159

# --- Modules ---
module Greeter
  abstract def greet(name : String) : String
end

# --- Enums ---
enum Color
  Red
  Green
  Blue

  def display : String
    to_s.downcase
  end
end

# --- Struct ---
struct Point
  property x : Float64
  property y : Float64

  def initialize(@x : Float64, @y : Float64)
  end

  def distance(other : Point) : Float64
    Math.sqrt((x - other.x) ** 2 + (y - other.y) ** 2)
  end

  def to_s(io : IO) : Nil
    io << "(#{x}, #{y})"
  end
end

# --- Abstract class ---
abstract class Animal
  getter name : String
  getter age : Int32

  def initialize(@name : String, @age : Int32 = 0)
  end

  abstract def speak : String

  def to_s(io : IO) : Nil
    io << "#{name}: #{speak}"
  end
end

# --- Class with inheritance ---
class Dog < Animal
  include Greeter

  getter breed : String

  def initialize(name : String, age : Int32, @breed : String = "Mixed")
    super(name, age)
  end

  def speak : String
    "Woof!"
  end

  def greet(person : String) : String
    "Woof! Hello, #{person}!"
  end
end

# --- Generic class ---
class Container(T)
  @items = [] of T

  def add(item : T) : Nil
    @items << item
  end

  def get(index : Int32) : T?
    @items[index]?
  end

  def size : Int32
    @items.size
  end

  def each(&block : T -> _)
    @items.each { |item| yield item }
  end
end

# --- Strings ---
single = 'A'  # Char in Crystal
double = "Hello, World!"
interpolated = "Sum: #{1 + 2}"
escaped = "tab\tnewline\nnull\0"
heredoc = <<-HEREDOC
  This is a heredoc
  with #{interpolated}
  HEREDOC
raw = %q(no interpolation #{here})
command = `echo hello`
symbol = :my_symbol
regex = /pattern[a-z]+/i

# --- Numbers ---
integer = 42
negative = -17
hex = 0xFF
octal = 0o77
binary = 0b1010
float_val = 3.14
scientific = 1.5e10
underscore = 1_000_000

i8_val = 42_i8
i16_val = 42_i16
i32_val = 42_i32
i64_val = 42_i64
u8_val = 42_u8
u32_val = 42_u32
f32_val = 3.14_f32
f64_val = 3.14_f64

# --- Booleans & Nil ---
yes = true
no = false
nothing = nil

# --- Variables ---
local_var = "local"
@instance_var = "instance" # in class context
@@class_var = "class"      # in class context

# --- Collections ---
array = [1, 2, 3, 4, 5]
empty_array = [] of Int32
tuple = {1, "hello", true}
named_tuple = {name: "Alice", age: 30}
hash = {"name" => "Alice", "age" => 30}
set = Set{1, 2, 3}
range = (1..10)
exclusive = (1...10)

# --- Control flow ---
if integer > 0
  puts "positive"
elsif integer < 0
  puts "negative"
else
  puts "zero"
end

unless integer == 0
  puts "not zero"
end

# Ternary
result = integer > 0 ? "positive" : "non-positive"

# --- Case ---
case integer
when 0
  puts "zero"
when 1..10
  puts "small"
when .> 100
  puts "big"
else
  puts "other"
end

# --- Case with type ---
value = 42.as(Int32 | String | Nil)
case value
when Int32
  puts "integer: #{value}"
when String
  puts "string: #{value}"
when nil
  puts "nil"
end

# --- Loops ---
10.times do |i|
  break if i == 5
  next if i == 3
  puts i
end

array.each do |item|
  puts item
end

i = 10
while i > 0
  i -= 1
end

until i >= 10
  i += 1
end

loop do
  i += 1
  break if i > 20
end

# --- Operators ---
sum = 1 + 2
diff = 5 - 3
prod = 4 * 2
quot = 10 / 3
modulo = 10 % 3
power = 2 ** 8
bit_and = 0xFF & 0x0F
bit_or = 0x10 | 0x01
bit_xor = 0xFF ^ 0x0F
bit_not = ~0
lshift = 1 << 4
rshift = 16 >> 2
logic = true && false || !nil
spaceship = 1 <=> 2

# --- Methods ---
def add(a : Int32, b : Int32) : Int32
  a + b
end

def greet(name : String, greeting = "Hello") : String
  "#{greeting}, #{name}!"
end

def variadic(*args : Int32) : Int32
  args.sum
end

# --- Blocks & Procs ---
square = ->(x : Int32) { x * x }
result = square.call(5)

def with_logging(&block : -> _)
  puts "Before"
  yield
  puts "After"
end

with_logging { puts "Inside" }

# --- Exception handling ---
begin
  raise "Something went wrong"
rescue ex : RuntimeError
  puts "Caught: #{ex.message}"
rescue ex : Exception
  puts "General: #{ex.message}"
ensure
  puts "cleanup"
end

# --- Type checking ---
dog = Dog.new("Rex", 5, "Labrador")
puts dog.speak
puts dog.is_a?(Animal)  # true
puts dog.responds_to?(:speak)  # true
puts typeof(dog)  # Dog
puts sizeof(Int32)  # 4
puts offsetof(Point, @x)

# --- Macros ---
macro define_method(name, content)
  def {{name}}
    {{content}}
  end
end

define_method(:hello, puts "hello!")

# --- Annotations ---
@[Deprecated("Use new_method instead")]
def old_method
end

# --- Alias ---
alias StringArray = Array(String)

# --- Lib (C bindings) ---
lib LibC
  fun puts(str : UInt8*) : Int32
end

# --- Pointers (unsafe) ---
ptr = Pointer(Int32).malloc(1)
ptr.value = 42
puts ptr.value

# --- with ---
dog = Dog.new("Max", 3)
with dog
  puts name
  puts speak
end

# --- Uninitialized ---
x = uninitialized Int32

# --- Self ---
class Example
  def self.class_method
    "class method on #{self}"
  end
end
