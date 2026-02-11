# Single line comment

"""
Module docstring.
Multi-line string used as comment.
"""

# --- Imports ---
import os
import sys
from pathlib import Path
from typing import (
    Any,
    Dict,
    List,
    Optional,
    Tuple,
    Union,
)
from collections import defaultdict
from functools import wraps
import json as json_module

# --- Constants ---
MAX_SIZE = 100
PI = 3.14159
__all__ = ["Animal", "Dog", "greet"]

# --- Numbers ---
integer = 42
negative = -17
hex_val = 0xFF
octal = 0o77
binary = 0b1010
float_val = 3.14
scientific = 1.5e10
complex_val = 3 + 4j
separator = 1_000_000

# --- Strings ---
single = 'single quoted'
double = "double quoted"
triple_single = '''
triple single
quoted
'''
triple_double = """
triple double
quoted
"""
raw = r"raw string \n no escape"
byte = b"byte string"
fstring = f"formatted: {integer + 1}"
fstring_nested = f"nested: {','.join(['a', 'b', 'c'])}"
escaped = "tab\tnewline\nnull\0"
unicode = "\u0048\u0065\u006C\u006C\u006F"

# --- Booleans & None ---
yes = True
no = False
nothing = None

# --- Variables ---
local_var = "local"

# --- Operators ---
sum_val = 1 + 2
diff = 5 - 3
prod = 4 * 2
quot = 10 / 3
floor_div = 10 // 3
modulo = 10 % 3
power = 2 ** 8
bit_and = 0xFF & 0x0F
bit_or = 0x10 | 0x01
bit_xor = 0xFF ^ 0x0F
bit_not = ~0
lshift = 1 << 4
rshift = 16 >> 2
logic = True and False or not None
identity = integer is not None
membership = 1 in [1, 2, 3]
comparison = 1 < 2 <= 3
walrus = (n := 10)
ternary = "yes" if yes else "no"

# --- Data structures ---
my_list = [1, 2, 3, 4, 5]
my_tuple = (1, 2, 3)
my_set = {1, 2, 3}
my_dict = {"name": "Alice", "age": 30}
empty_dict = {}
empty_list = []
empty_tuple = ()
empty_set = set()

# --- Comprehensions ---
list_comp = [x * 2 for x in range(10) if x % 2 == 0]
dict_comp = {k: v for k, v in my_dict.items()}
set_comp = {x ** 2 for x in range(5)}
gen_expr = sum(x for x in range(100))

# --- Functions ---
def greet(name: str, greeting: str = "Hello") -> str:
    """Greet someone."""
    return f"{greeting}, {name}!"


def variadic(*args: Any, **kwargs: Any) -> None:
    """Function with variadic arguments."""
    for arg in args:
        print(arg)
    for key, value in kwargs.items():
        print(f"{key}={value}")


# --- Lambda ---
double = lambda x: x * 2
key_func = lambda item: item[1]

# --- Decorators ---
def my_decorator(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        print(f"Calling {func.__name__}")
        result = func(*args, **kwargs)
        print(f"Done {func.__name__}")
        return result
    return wrapper


@my_decorator
def decorated_function():
    """A decorated function."""
    pass


# --- Classes ---
class Animal:
    """Base animal class."""
    count: int = 0

    def __init__(self, name: str, age: int = 0) -> None:
        self.name = name
        self.age = age
        Animal.count += 1

    def speak(self) -> str:
        raise NotImplementedError

    def __repr__(self) -> str:
        return f"{self.__class__.__name__}({self.name!r})"

    def __str__(self) -> str:
        return f"{self.name}: {self.speak()}"

    @classmethod
    def get_count(cls) -> int:
        return cls.count

    @staticmethod
    def is_valid_name(name: str) -> bool:
        return len(name) > 0

    @property
    def info(self) -> str:
        return f"{self.name} (age {self.age})"


class Dog(Animal):
    """Dog class."""

    def __init__(self, name: str, age: int, breed: str = "Mixed") -> None:
        super().__init__(name, age)
        self._breed = breed

    def speak(self) -> str:
        return "Woof!"


# --- Control flow ---
if integer > 0:
    print("positive")
elif integer < 0:
    print("negative")
else:
    print("zero")

# --- Match statement (Python 3.10+) ---
match integer:
    case 0:
        print("zero")
    case n if n > 0:
        print(f"positive: {n}")
    case _:
        print("negative")

match my_dict:
    case {"name": str() as name, "age": int() as age}:
        print(f"{name} is {age}")

# --- Loops ---
for i in range(10):
    if i == 5:
        break
    if i == 3:
        continue
    print(i)
else:
    print("completed")

j = 10
while j > 0:
    j -= 1
else:
    print("done")

# --- Exception handling ---
try:
    raise ValueError("something went wrong")
except ValueError as e:
    print(f"Caught: {e}")
except (TypeError, KeyError):
    print("Type or Key error")
except Exception:
    print("Unexpected")
else:
    print("No error")
finally:
    print("cleanup")

# --- Context manager ---
with open("/dev/null", "r") as f:
    content = f.read()

# --- Assert ---
assert integer == 42, "Expected 42"

# --- Delete ---
temp = "to be deleted"
del temp

# --- Global/Nonlocal ---
def outer():
    x = 10
    def inner():
        nonlocal x
        x = 20
    inner()

def use_global():
    global integer
    integer = 0

# --- Async/Await ---
async def fetch_data(url: str) -> dict:
    """Async function example."""
    pass

async def main():
    result = await fetch_data("https://example.com")

# --- Generators ---
def fibonacci():
    a, b = 0, 1
    while True:
        yield a
        a, b = b, a + b

# --- Type aliases (Python 3.12+) ---
type Vector = list[float]
type Matrix = list[Vector]

# --- Unpacking ---
a, b, *rest = [1, 2, 3, 4, 5]
first, *middle, last = range(10)
{**my_dict, "extra": True}

# --- Slice ---
sliced = my_list[1:4]
stepped = my_list[::2]
reversed_list = my_list[::-1]

# --- Ellipsis ---
def placeholder() -> None:
    ...

# --- exec/print as keywords ---
# (Python 2 compatibility noted in node map)
print("Hello, World!")
