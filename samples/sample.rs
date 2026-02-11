// Line comment
/* Block comment */
/// Doc comment for the module
//! Inner doc comment

// --- Modules & Imports ---
use std::collections::HashMap;
use std::fmt::{self, Display};
use std::io::{self, Read, Write};

mod helper {
    pub fn add(a: i32, b: i32) -> i32 {
        a + b
    }
}

// --- Constants & Statics ---
const MAX_SIZE: usize = 100;
static GREETING: &str = "Hello, World!";
static mut COUNTER: i32 = 0;

// --- Enums ---
#[derive(Debug, Clone, PartialEq)]
enum Color {
    Red,
    Green,
    Blue,
    Custom(u8, u8, u8),
}

#[derive(Debug)]
enum Shape {
    Circle { radius: f64 },
    Rectangle { width: f64, height: f64 },
    Triangle(f64, f64, f64),
}

// --- Structs ---
#[derive(Debug, Clone)]
struct Point {
    x: f64,
    y: f64,
}

struct Container<T> {
    items: Vec<T>,
}

// Tuple struct
struct Pair<T>(T, T);

// Unit struct
struct Unit;

// --- Traits ---
trait Animal: Display {
    fn name(&self) -> &str;
    fn speak(&self) -> String;

    fn greet(&self) -> String {
        format!("Hi, I'm {} and I say {}", self.name(), self.speak())
    }
}

trait Drawable {
    fn draw(&self);
    fn area(&self) -> f64;
}

// --- Implementations ---
impl Point {
    fn new(x: f64, y: f64) -> Self {
        Self { x, y }
    }

    fn distance(&self, other: &Point) -> f64 {
        ((self.x - other.x).powi(2) + (self.y - other.y).powi(2)).sqrt()
    }
}

impl Display for Point {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "({}, {})", self.x, self.y)
    }
}

impl<T> Container<T> {
    fn new() -> Self {
        Container { items: Vec::new() }
    }

    fn add(&mut self, item: T) {
        self.items.push(item);
    }

    fn get(&self, index: usize) -> Option<&T> {
        self.items.get(index)
    }

    fn len(&self) -> usize {
        self.items.len()
    }
}

impl Drawable for Shape {
    fn draw(&self) {
        println!("Drawing {:?}", self);
    }

    fn area(&self) -> f64 {
        match self {
            Shape::Circle { radius } => std::f64::consts::PI * radius * radius,
            Shape::Rectangle { width, height } => width * height,
            Shape::Triangle(a, b, c) => {
                let s = (a + b + c) / 2.0;
                (s * (s - a) * (s - b) * (s - c)).sqrt()
            }
        }
    }
}

// --- Functions ---
fn add(a: i32, b: i32) -> i32 {
    a + b
}

fn greet(name: &str) -> String {
    format!("Hello, {}!", name)
}

fn divide(a: f64, b: f64) -> Result<f64, String> {
    if b == 0.0 {
        Err("Division by zero".to_string())
    } else {
        Ok(a / b)
    }
}

// Generic function with trait bounds
fn largest<T: PartialOrd>(list: &[T]) -> Option<&T> {
    let mut max = list.first()?;
    for item in list {
        if item > max {
            max = item;
        }
    }
    Some(max)
}

// Async function
async fn fetch_data(url: &str) -> Result<String, Box<dyn std::error::Error>> {
    Ok(format!("Data from {}", url))
}

fn main() {
    // --- Strings ---
    let simple = "Hello, World!";
    let escaped = "tab\tnewline\nnull\0";
    let raw = r"raw string \n no escape";
    let raw_hash = r#"raw with "quotes" inside"#;
    let byte_str = b"byte string";
    let char_val = 'A';
    let unicode_char = '\u{1F600}';

    // --- Numbers ---
    let integer: i32 = 42;
    let unsigned: u64 = 100;
    let float: f64 = 3.14;
    let hex = 0xFF;
    let octal = 0o77;
    let binary = 0b1010;
    let separator = 1_000_000;
    let byte = b'A';
    let inferred = 42;

    // --- Booleans ---
    let yes: bool = true;
    let no: bool = false;

    // --- Variables ---
    let immutable = "can't change";
    let mut mutable = "can change";
    mutable = "changed";

    let (a, b, c) = (1, 2, 3);
    let Point { x, y } = Point::new(1.0, 2.0);

    // --- References ---
    let reference = &integer;
    let mut_ref = &mut mutable;
    let deref = *reference;

    // --- Control flow ---
    if integer > 0 {
        println!("positive");
    } else if integer < 0 {
        println!("negative");
    } else {
        println!("zero");
    }

    // --- Match ---
    match integer {
        0 => println!("zero"),
        1..=10 => println!("small"),
        n if n > 100 => println!("big: {}", n),
        _ => println!("other"),
    }

    match Color::Custom(255, 0, 0) {
        Color::Red => println!("red"),
        Color::Custom(r, g, b) => println!("rgb({}, {}, {})", r, g, b),
        _ => println!("other"),
    }

    // --- Loops ---
    for i in 0..10 {
        if i == 5 {
            break;
        }
        if i == 3 {
            continue;
        }
        println!("{}", i);
    }

    for item in &[1, 2, 3] {
        println!("{}", item);
    }

    let mut j = 10;
    while j > 0 {
        j -= 1;
    }

    loop {
        j += 1;
        if j >= 5 {
            break;
        }
    }

    // Loop with label
    'outer: for i in 0..3 {
        for j in 0..3 {
            if j == 1 {
                continue 'outer;
            }
            if i == 2 {
                break 'outer;
            }
        }
    }

    // Loop as expression
    let result = loop {
        j += 1;
        if j > 10 {
            break j * 2;
        }
    };

    // --- Operators ---
    let sum = 1 + 2;
    let diff = 5 - 3;
    let prod = 4 * 2;
    let quot = 10 / 3;
    let modulo = 10 % 3;
    let neg = -sum;
    let bit_and = 0xFF & 0x0F;
    let bit_or = 0x10 | 0x01;
    let bit_xor = 0xFF ^ 0x0F;
    let bit_not = !0u32;
    let lshift = 1 << 4;
    let rshift = 16 >> 2;
    let logic = true && false || !true;
    let range = 0..10;
    let range_inclusive = 0..=10;

    // --- Option & Result ---
    let some_val: Option<i32> = Some(42);
    let none_val: Option<i32> = None;
    let unwrapped = some_val.unwrap_or(0);

    let ok_val: Result<i32, String> = Ok(42);
    let err_val: Result<i32, String> = Err("error".to_string());

    // --- Error handling ---
    match divide(10.0, 3.0) {
        Ok(result) => println!("Result: {}", result),
        Err(e) => println!("Error: {}", e),
    }

    // Try operator
    fn try_divide() -> Result<(), String> {
        let result = divide(10.0, 0.0)?;
        println!("{}", result);
        Ok(())
    }

    // --- Closures ---
    let closure = |x: i32| x * 2;
    let closure_block = |x: i32, y: i32| -> i32 {
        let sum = x + y;
        sum * 2
    };
    let capture = move || println!("{}", integer);

    // --- Iterators ---
    let doubled: Vec<i32> = (0..5).map(|x| x * 2).collect();
    let evens: Vec<i32> = (0..10).filter(|x| x % 2 == 0).collect();
    let sum: i32 = (1..=100).sum();

    // --- Collections ---
    let mut vec = vec![1, 2, 3];
    vec.push(4);

    let mut map = HashMap::new();
    map.insert("key", "value");
    map.entry("key2").or_insert("default");

    // --- Box, Rc, Arc ---
    let boxed: Box<i32> = Box::new(42);
    let _deref = *boxed;

    // --- Type casting ---
    let float_val = integer as f64;
    let truncated = 3.99f64 as i32;

    // --- Unsafe ---
    unsafe {
        COUNTER += 1;
        println!("Counter: {}", COUNTER);
    }

    // --- Macros ---
    println!("Hello, {}!", "World");
    format!("formatted {}", integer);
    vec![1, 2, 3];
    assert!(true);
    assert_eq!(1 + 1, 2);
    dbg!(integer);

    // --- Struct initialization ---
    let p1 = Point { x: 1.0, y: 2.0 };
    let p2 = Point { x: 4.0, ..p1 };

    // --- If let / While let ---
    if let Some(val) = some_val {
        println!("Got: {}", val);
    }

    let mut stack = vec![1, 2, 3];
    while let Some(top) = stack.pop() {
        println!("{}", top);
    }

    // --- Let chain ---
    if let Some(x) = some_val && x > 0 {
        println!("positive some: {}", x);
    }

    println!("Done!");
}

// --- Macro definition ---
macro_rules! say_hello {
    () => {
        println!("Hello!");
    };
    ($name:expr) => {
        println!("Hello, {}!", $name);
    };
}

// --- Tests ---
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_add() {
        assert_eq!(add(1, 2), 3);
    }

    #[test]
    #[should_panic(expected = "Division by zero")]
    fn test_divide_by_zero() {
        divide(1.0, 0.0).unwrap();
    }
}
