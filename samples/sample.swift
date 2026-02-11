// Line comment
/* Block comment */
/// Doc comment
/**
 * Multi-line
 * doc comment
 */

import Foundation
import SwiftUI

// --- Constants & Variables ---
let pi = 3.14159
let maxSize = 100
var counter = 0

// --- Enums ---
enum Color: String, CaseIterable {
    case red = "Red"
    case green = "Green"
    case blue = "Blue"

    var display: String {
        return rawValue.lowercased()
    }
}

enum Shape {
    case circle(radius: Double)
    case rectangle(width: Double, height: Double)
    indirect case compound(Shape, Shape)

    var area: Double {
        switch self {
        case .circle(let radius):
            return Double.pi * radius * radius
        case .rectangle(let width, let height):
            return width * height
        case .compound(let a, let b):
            return a.area + b.area
        }
    }
}

// --- Protocols ---
protocol Greeter {
    func greet(name: String) -> String
}

protocol Drawable {
    func draw()
    var description: String { get }
}

extension Drawable {
    func draw() {
        print("Drawing \(description)")
    }
}

// --- Structs ---
struct Point: CustomStringConvertible {
    var x: Double
    var y: Double

    var description: String {
        return "(\(x), \(y))"
    }

    func distance(to other: Point) -> Double {
        return sqrt(pow(x - other.x, 2) + pow(y - other.y, 2))
    }

    mutating func translate(dx: Double, dy: Double) {
        x += dx
        y += dy
    }
}

// --- Classes ---
class Animal: CustomStringConvertible {
    let name: String
    var age: Int

    init(name: String, age: Int = 0) {
        self.name = name
        self.age = age
    }

    func speak() -> String {
        fatalError("Must override")
    }

    var description: String {
        return "\(name): \(speak())"
    }

    deinit {
        print("\(name) deallocated")
    }
}

class Dog: Animal, Greeter {
    private(set) var breed: String

    init(name: String, age: Int, breed: String = "Mixed") {
        self.breed = breed
        super.init(name: name, age: age)
    }

    override func speak() -> String {
        return "Woof!"
    }

    func greet(name: String) -> String {
        return "Woof! Hello, \(name)!"
    }
}

// --- Generics ---
class Container<T> {
    private var items: [T] = []

    func add(_ item: T) {
        items.append(item)
    }

    func get(_ index: Int) -> T? {
        guard index < items.count else { return nil }
        return items[index]
    }

    var count: Int {
        return items.count
    }
}

func largest<T: Comparable>(_ array: [T]) -> T? {
    guard var result = array.first else { return nil }
    for item in array {
        if item > result {
            result = item
        }
    }
    return result
}

// --- Extensions ---
extension Int {
    var squared: Int {
        return self * self
    }

    func times(_ closure: () -> Void) {
        for _ in 0..<self {
            closure()
        }
    }
}

extension String {
    subscript(index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
}

// --- Typealias ---
typealias StringArray = [String]
typealias Handler = (String) -> Void

// --- Functions ---
func add(_ a: Int, _ b: Int) -> Int {
    return a + b
}

func greet(name: String, greeting: String = "Hello") -> String {
    return "\(greeting), \(name)!"
}

func divide(_ a: Double, by b: Double) throws -> Double {
    guard b != 0 else {
        throw NSError(domain: "Math", code: 1, userInfo: [NSLocalizedDescriptionKey: "Division by zero"])
    }
    return a / b
}

// Variadic
func sum(_ numbers: Int...) -> Int {
    return numbers.reduce(0, +)
}

// Inout
func swap(_ a: inout Int, _ b: inout Int) {
    let temp = a
    a = b
    b = temp
}

// --- Async/Await ---
func fetchData(from url: String) async throws -> String {
    try await Task.sleep(nanoseconds: 1_000_000)
    return "Data from \(url)"
}

// --- Main ---
func main() {
    // --- Strings ---
    let simple = "Hello, World!"
    let interpolated = "Sum: \(1 + 2)"
    let multiline = """
        This is a multi-line
        string literal with
        "quotes" inside
        """
    let escaped = "tab\tnewline\nnull\0"
    let raw = #"raw string \n no escape"#
    let rawInterp = #"raw with \#(counter)"#

    // --- Numbers ---
    let integer = 42
    let float: Float = 3.14
    let double: Double = 2.71828
    let hex = 0xFF
    let octal = 0o77
    let binary = 0b1010
    let separator = 1_000_000

    // --- Booleans & Nil ---
    let yes: Bool = true
    let no: Bool = false
    var optional: String? = nil
    let forced: String = optional ?? "default"

    // --- Type annotations ---
    let typed: Int = 42
    let array: [Int] = [1, 2, 3]
    let dict: [String: Int] = ["a": 1, "b": 2]
    let tuple: (Int, String) = (1, "hello")
    let closure: (Int) -> Int = { $0 * 2 }

    // --- Control flow ---
    if integer > 0 {
        print("positive")
    } else if integer < 0 {
        print("negative")
    } else {
        print("zero")
    }

    // Guard
    guard let value = optional else {
        print("nil")
        return
    }

    // Switch
    switch integer {
    case 0:
        print("zero")
    case 1...10:
        print("small")
    case let n where n > 100:
        print("big: \(n)")
    default:
        print("other")
    }

    // Switch with enum
    let shape = Shape.circle(radius: 5.0)
    switch shape {
    case .circle(let radius):
        print("Circle: \(radius)")
    case .rectangle(let w, let h):
        print("Rect: \(w)x\(h)")
    case .compound:
        print("Compound")
    }

    // --- Loops ---
    for i in 0..<10 {
        if i == 5 { break }
        if i == 3 { continue }
        print(i)
    }

    for item in array {
        print(item)
    }

    for (key, value) in dict {
        print("\(key): \(value)")
    }

    var j = 10
    while j > 0 {
        j -= 1
    }

    repeat {
        j += 1
    } while j < 5

    // Labeled loop
    outer: for i in 0..<3 {
        for k in 0..<3 {
            if k == 1 { continue outer }
            if i == 2 { break outer }
        }
    }

    // --- Operators ---
    let sum = 1 + 2
    let diff = 5 - 3
    let prod = 4 * 2
    let quot = 10 / 3
    let mod = 10 % 3
    let neg = -sum
    let logic = true && false || !true
    let ternary = sum > 0 ? "yes" : "no"
    let nilCoalesce = optional ?? "default"

    // --- Optionals ---
    var name: String? = "Alice"
    let length = name?.count
    let upper = name?.uppercased()
    let unwrapped = name!

    if let n = name {
        print("Name: \(n)")
    }

    // Optional chaining
    let firstChar = name?.first?.uppercased()

    // --- Error handling ---
    do {
        let result = try divide(10, by: 3)
        print("Result: \(result)")
    } catch {
        print("Error: \(error)")
    }

    let tryResult = try? divide(10, by: 0)
    let forceResult = try! divide(10, by: 2)

    // --- Closures ---
    let double = { (x: Int) -> Int in
        return x * 2
    }

    let shortClosure: (Int) -> Int = { $0 * 2 }

    let numbers = [3, 1, 4, 1, 5, 9, 2, 6]
    let sorted = numbers.sorted { $0 < $1 }
    let doubled = numbers.map { $0 * 2 }
    let evens = numbers.filter { $0 % 2 == 0 }
    let total = numbers.reduce(0, +)

    // Trailing closure
    numbers.forEach { number in
        print(number)
    }

    // --- Collections ---
    var mutableArray = [1, 2, 3]
    mutableArray.append(4)
    mutableArray += [5, 6]

    var mutableDict = ["a": 1, "b": 2]
    mutableDict["c"] = 3
    mutableDict.removeValue(forKey: "a")

    var mutableSet: Set<Int> = [1, 2, 3]
    mutableSet.insert(4)
    mutableSet.remove(1)

    // --- Defer ---
    defer {
        print("cleanup")
    }

    // --- Object creation ---
    let dog = Dog(name: "Rex", age: 5, breed: "Labrador")
    print(dog.speak())
    print(dog.greet(name: "World"))

    // Type checking
    if dog is Animal {
        print("Is an animal")
    }

    if let animal = dog as? Animal {
        print("Cast: \(animal.name)")
    }

    // --- Struct usage ---
    var p1 = Point(x: 1.0, y: 2.0)
    let p2 = Point(x: 4.0, y: 6.0)
    print(p1.distance(to: p2))
    p1.translate(dx: 1.0, dy: 1.0)

    // --- Async ---
    Task {
        do {
            let data = try await fetchData(from: "https://example.com")
            print(data)
        } catch {
            print("Error: \(error)")
        }
    }

    // --- Self ---
    print(type(of: dog))

    // --- Subscript ---
    let char = "Hello"[0]
    print(char)

    // --- Lazy ---
    lazy var expensive = {
        return "computed"
    }()

    // --- Property observers (in class context) ---
    // willSet, didSet

    // --- Associated types ---
    // protocol Collection {
    //     associatedtype Element
    // }

    // --- Where clause ---
    func process<T>(_ items: [T]) where T: Comparable, T: Hashable {
        print(items.sorted())
    }

    // --- Operator declaration ---
    // prefix operator +++
    // infix operator **: MultiplicationPrecedence
    // precedencegroup MyPrecedence { ... }

    print("Done!")
}

// --- Computed property ---
struct Temperature {
    var celsius: Double

    var fahrenheit: Double {
        get {
            return celsius * 9.0 / 5.0 + 32.0
        }
        set {
            celsius = (newValue - 32.0) * 5.0 / 9.0
        }
    }

    static let boiling = Temperature(celsius: 100.0)
    static let freezing = Temperature(celsius: 0.0)
}

// --- Final class ---
final class Singleton {
    static let shared = Singleton()
    private init() {}
}

// --- Property wrapper (SwiftUI style) ---
@propertyWrapper
struct Clamped {
    var wrappedValue: Int {
        didSet {
            wrappedValue = min(max(wrappedValue, range.lowerBound), range.upperBound)
        }
    }
    let range: ClosedRange<Int>

    init(wrappedValue: Int, _ range: ClosedRange<Int>) {
        self.range = range
        self.wrappedValue = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }
}
