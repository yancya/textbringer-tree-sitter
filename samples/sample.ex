# Single line comment

# Elixir sample - functional programming on the BEAM

# --- Module ---
defmodule Sample do
  @moduledoc """
  Sample module demonstrating Elixir syntax.
  """

  # --- Module attributes ---
  @max_size 100
  @pi 3.14159
  @greeting "Hello, World!"

  # --- Structs ---
  defmodule Point do
    @enforce_keys [:x, :y]
    defstruct [:x, :y, z: 0.0]
  end

  defmodule User do
    defstruct [:name, :age, active: true]
  end

  # --- Types ---
  @type color :: :red | :green | :blue
  @type result :: {:ok, any()} | {:error, String.t()}

  # --- Functions ---
  @doc "Add two numbers"
  @spec add(number(), number()) :: number()
  def add(a, b) do
    a + b
  end

  @spec greet(String.t(), String.t()) :: String.t()
  def greet(name, greeting \\ "Hello") do
    "#{greeting}, #{name}!"
  end

  # --- Pattern matching in function heads ---
  def describe(:red), do: "Red color"
  def describe(:green), do: "Green color"
  def describe(:blue), do: "Blue color"
  def describe(_), do: "Unknown color"

  # --- Guards ---
  def classify(n) when is_integer(n) and n > 0, do: :positive
  def classify(n) when is_integer(n) and n < 0, do: :negative
  def classify(0), do: :zero
  def classify(_), do: :not_a_number

  # --- Private functions ---
  defp helper(value) do
    value * 2
  end

  # --- Default arguments ---
  def repeat(str, times \\ 3) do
    String.duplicate(str, times)
  end

  # --- Multi-clause with when ---
  def safe_divide(a, b) when b != 0 do
    {:ok, a / b}
  end

  def safe_divide(_a, 0) do
    {:error, "Division by zero"}
  end

  # --- Main function ---
  def run do
    # --- Atoms ---
    status = :ok
    error = :error
    module_atom = Sample

    # --- Strings ---
    simple = "Hello, World!"
    interpolated = "Sum: #{1 + 2}"
    escaped = "tab\tnewline\n"
    heredoc = """
    This is a heredoc
    with #{interpolated}
    """
    charlist = 'charlist (list of integers)'
    sigil_string = ~s(sigil string with #{interpolated})
    sigil_raw = ~S(raw sigil, no #{interpolation})
    regex = ~r/pattern[a-z]+/i
    wordlist = ~w(apple banana cherry)a

    # --- Numbers ---
    integer = 42
    negative = -17
    hex = 0xFF
    octal = 0o77
    binary = 0b1010
    float_val = 3.14
    scientific = 1.5e10
    underscore = 1_000_000

    # --- Booleans & Nil ---
    yes = true
    no = false
    nothing = nil

    # --- Collections ---
    list = [1, 2, 3, 4, 5]
    tuple = {1, "hello", true}
    map = %{name: "Alice", age: 30}
    keyword = [name: "Alice", age: 30]
    mapset = MapSet.new([1, 2, 3])
    range = 1..10
    struct = %Point{x: 1.0, y: 2.0}

    # --- Operators ---
    sum = 1 + 2
    diff = 5 - 3
    prod = 4 * 2
    quot = 10 / 3
    int_div = div(10, 3)
    modulo = rem(10, 3)
    concat = "Hello" <> " " <> "World"
    list_concat = [1, 2] ++ [3, 4]
    list_diff = [1, 2, 3] -- [2]
    logic = true and false
    logic2 = true or false
    logic3 = not false
    strict_and = true && false
    strict_or = true || false
    strict_not = !nil
    pipe = "hello" |> String.upcase() |> String.reverse()
    equality = 1 == 1.0
    strict_eq = 1 === 1

    # --- Pattern matching ---
    {a, b, c} = {1, 2, 3}
    [head | tail] = [1, 2, 3, 4]
    %{name: name} = %{name: "Alice", age: 30}
    ^integer = 42  # Pin operator

    # --- Control flow ---
    # If/else
    if integer > 0 do
      IO.puts("positive")
    else
      IO.puts("non-positive")
    end

    # Unless
    unless integer == 0 do
      IO.puts("not zero")
    end

    # Case
    case {1, 2, 3} do
      {1, x, 3} when x > 0 ->
        IO.puts("matched: #{x}")
      _ ->
        IO.puts("no match")
    end

    # Cond
    cond do
      integer > 100 -> IO.puts("big")
      integer > 0 -> IO.puts("positive")
      true -> IO.puts("other")
    end

    # With
    with {:ok, result} <- safe_divide(10, 3),
         formatted <- Float.round(result, 2) do
      IO.puts("Result: #{formatted}")
    else
      {:error, reason} -> IO.puts("Error: #{reason}")
    end

    # --- Loops (recursion + Enum) ---
    Enum.each(1..5, fn i ->
      IO.puts(i)
    end)

    doubled = Enum.map(list, &(&1 * 2))
    evens = Enum.filter(list, &(rem(&1, 2) == 0))
    total = Enum.reduce(list, 0, &(&1 + &2))

    # Comprehension
    for x <- 1..10, rem(x, 2) == 0, do: x * x
    for {k, v} <- map, into: %{}, do: {k, "#{v}!"}

    # --- Anonymous functions ---
    square = fn x -> x * x end
    result = square.(5)

    multi = fn
      0 -> "zero"
      n when n > 0 -> "positive"
      _ -> "negative"
    end

    # Capture operator
    double = &(&1 * 2)
    add_fn = &add/2

    # --- Try / Rescue / Catch ---
    try do
      raise "Something went wrong"
    rescue
      e in RuntimeError ->
        IO.puts("Caught: #{e.message}")
    catch
      :throw, value ->
        IO.puts("Caught throw: #{value}")
    after
      IO.puts("cleanup")
    end

    # --- Processes ---
    pid = spawn(fn -> IO.puts("spawned") end)
    send(pid, {:hello, "world"})

    receive do
      {:hello, msg} ->
        IO.puts("Got: #{msg}")
    after
      1000 ->
        IO.puts("timeout")
    end

    # --- Structs ---
    user = %User{name: "Alice", age: 30}
    updated = %{user | age: 31}
    IO.puts("#{user.name} is #{user.age}")

    # --- Bitstrings ---
    <<a::8, b::8, rest::binary>> = "Hello"
    bits = <<1::1, 0::1, 1::1>>

    # --- Protocols ---
    # (defined separately)

    :ok
  end
end

# --- Protocol ---
defprotocol Displayable do
  @doc "Convert to display string"
  def display(value)
end

defimpl Displayable, for: Integer do
  def display(value), do: "Integer: #{value}"
end

defimpl Displayable, for: BitString do
  def display(value), do: "String: #{value}"
end

# --- Macros ---
defmodule MyMacro do
  defmacro unless(condition, do: block) do
    quote do
      if !unquote(condition) do
        unquote(block)
      end
    end
  end
end

# --- Use / Import / Alias / Require ---
defmodule Consumer do
  alias Sample.Point
  alias Sample.User, as: U
  import Enum, only: [map: 2, filter: 2]
  require Logger
  use GenServer

  def init(state) do
    {:ok, state}
  end
end

# --- GenServer example ---
defmodule Counter do
  use GenServer

  # Client API
  def start_link(initial \\ 0) do
    GenServer.start_link(__MODULE__, initial, name: __MODULE__)
  end

  def increment, do: GenServer.cast(__MODULE__, :increment)
  def get_count, do: GenServer.call(__MODULE__, :get)

  # Server callbacks
  @impl true
  def init(count), do: {:ok, count}

  @impl true
  def handle_cast(:increment, count), do: {:noreply, count + 1}

  @impl true
  def handle_call(:get, _from, count), do: {:reply, count, count}
end
