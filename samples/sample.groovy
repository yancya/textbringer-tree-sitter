// Line comment
/* Block comment */
/**
 * Groovydoc comment
 * @author Sample
 */

package com.example.sample

import java.util.List
import java.util.Map

// --- Constants ---
final PI = 3.14159
final MAX_SIZE = 100

// --- Enums ---
enum Color {
    RED, GREEN, BLUE

    String display() {
        return name().toLowerCase()
    }
}

// --- Interface ---
interface Greeter {
    String greet(String name)
}

// --- Trait ---
trait Loggable {
    void log(String message) {
        println "[LOG] ${message}"
    }
}

// --- Abstract class ---
abstract class Animal {
    String name
    int age

    Animal(String name, int age = 0) {
        this.name = name
        this.age = age
    }

    abstract String speak()

    @Override
    String toString() {
        return "${name}: ${speak()}"
    }
}

// --- Class with trait and interface ---
class Dog extends Animal implements Greeter, Loggable {
    String breed

    Dog(String name, int age, String breed = 'Mixed') {
        super(name, age)
        this.breed = breed
    }

    @Override
    String speak() {
        return 'Woof!'
    }

    @Override
    String greet(String person) {
        log("Greeting ${person}")
        return "Woof! Hello, ${person}!"
    }
}

// --- Strings ---
def single = 'single quoted'
def double = "double quoted with ${1 + 2}"
def gstring = "GString: name=${single}"
def multilineSingle = '''
multi-line
single quoted
'''
def multilineDouble = """
multi-line
double: ${single}
"""
def slashy = /pattern[a-z]+/
def dollarSlashy = $/dollar/slashy/$
def escaped = "tab\tnewline\n"

// --- Numbers ---
def integer = 42
def negative = -17
def longVal = 1234567890L
def bigInt = 1234567890123456789G
def floatVal = 3.14f
def doubleVal = 2.71828d
def bigDec = 3.14159G
def hex = 0xFF
def octal = 0o77
def binary = 0b1010

// --- Booleans & Null ---
def yes = true
def no = false
def nothing = null

// --- Variables ---
def dynamicVar = 'dynamic'
String typedVar = 'typed'
var inferredVar = 'inferred'  // Groovy 3+

// --- Collections ---
def list = [1, 2, 3, 4, 5]
def emptyList = []
def linkedList = [1, 2, 3] as LinkedList

def map = [name: 'Alice', age: 30, active: true]
def emptyMap = [:]
def typedMap = ['key': 'value'] as HashMap

def range = 1..10
def halfOpen = 1..<10

def set = [1, 2, 3] as Set

// --- Control flow ---
if (integer > 0) {
    println 'positive'
} else if (integer < 0) {
    println 'negative'
} else {
    println 'zero'
}

// --- Switch ---
switch (integer) {
    case 0:
        println 'zero'
        break
    case 1..10:
        println 'small'
        break
    case ~/\d{3}/:
        println 'three digits'
        break
    case Integer:
        println 'integer type'
        break
    default:
        println 'other'
        break
}

// --- Loops ---
for (i in 0..<10) {
    if (i == 5) break
    if (i == 3) continue
    println i
}

for (item in list) {
    println item
}

def j = 10
while (j > 0) {
    j--
}

do {
    j++
} while (j < 5)

// --- Closures ---
def square = { int x -> x * x }
def printer = { println it }
def multiLine = { a, b ->
    def sum = a + b
    return sum * 2
}

list.each { println it }
def doubled = list.collect { it * 2 }
def evens = list.findAll { it % 2 == 0 }

// --- Operators ---
def sum = 1 + 2
def concat = 'Hello' + ' ' + 'World'
def spaceship = 1 <=> 2
def elvis = nothing ?: 'default'
def safe = nothing?.toString()
def spread = list*.toString()
def membership = 1 in list
def typeCheck = integer instanceof Integer
def power = 2 ** 8
def regex = 'hello' ==~ /h.*/

// --- GPath ---
def xmlText = '<root><child name="test">value</child></root>'

// --- Methods ---
def add(int a, int b) {
    return a + b
}

String greetPerson(String name, String greeting = 'Hello') {
    "${greeting}, ${name}!"
}

def variadic(String... args) {
    args.each { println it }
}

// --- Exception handling ---
try {
    throw new RuntimeException('Something went wrong')
} catch (RuntimeException e) {
    println "Caught: ${e.message}"
} catch (Exception e) {
    println "General: ${e.message}"
} finally {
    println 'cleanup'
}

// --- Assert ---
assert integer == 42
assert list.size() == 5 : 'Expected 5 items'

// --- As / Type coercion ---
def str = 42 as String
def nums = '1,2,3'.split(',') as List

// --- Object creation ---
def dog = new Dog('Rex', 5, 'Labrador')
println dog.speak()
println dog.greet('World')

if (dog instanceof Animal) {
    println "Is an animal"
}

// --- Safe navigation ---
def length = dog?.name?.length()

// --- Spread operator ---
def names = [new Dog('A', 1), new Dog('B', 2)]*.name

// --- Builder pattern (typical Groovy) ---
def builder = new StringBuilder()
builder.with {
    append 'Hello'
    append ', '
    append 'World!'
}
println builder.toString()
