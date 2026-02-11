// Line comment
/* Block comment */
/**
 * Javadoc comment
 * @author Sample
 */

package com.example.sample;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Optional;
import java.util.stream.Collectors;

// --- Enum ---
enum Color {
    RED("red"),
    GREEN("green"),
    BLUE("blue");

    private final String name;

    Color(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }
}

// --- Interface ---
interface Greeter {
    String greet(String name);

    default String farewell(String name) {
        return "Goodbye, " + name + "!";
    }

    static Greeter create() {
        return name -> "Hello, " + name + "!";
    }
}

// --- Abstract class ---
abstract class Animal {
    protected String name;

    public Animal(String name) {
        this.name = name;
    }

    public abstract String speak();

    @Override
    public String toString() {
        return name + " says " + speak();
    }
}

// --- Record (Java 16+) ---
record Point(double x, double y) {
    double distanceTo(Point other) {
        return Math.sqrt(Math.pow(x - other.x, 2) + Math.pow(y - other.y, 2));
    }
}

// --- Sealed class (Java 17+) ---
sealed class Shape permits Circle, Rectangle {
    public double area() { return 0; }
}

final class Circle extends Shape {
    private final double radius;

    Circle(double radius) {
        this.radius = radius;
    }

    @Override
    public double area() {
        return Math.PI * radius * radius;
    }
}

final class Rectangle extends Shape {
    private final double width, height;

    Rectangle(double width, double height) {
        this.width = width;
        this.height = height;
    }

    @Override
    public double area() {
        return width * height;
    }
}

// --- Generic class ---
class Container<T extends Comparable<T>> {
    private final List<T> items = new ArrayList<>();

    public void add(T item) {
        items.add(item);
    }

    public Optional<T> max() {
        return items.stream().max(T::compareTo);
    }
}

// --- Main class ---
public class Sample {
    // --- Constants ---
    public static final int MAX_SIZE = 100;
    private static final String GREETING = "Hello";

    // --- Instance fields ---
    private final String name;
    private int count;
    private volatile boolean running;
    private transient String temp;

    // --- Constructor ---
    public Sample(String name) {
        this.name = name;
        this.count = 0;
        this.running = true;
    }

    // --- Methods ---
    public synchronized void increment() {
        count++;
    }

    public String getName() {
        return name;
    }

    // --- Varargs ---
    public static int sum(int... numbers) {
        int total = 0;
        for (int n : numbers) {
            total += n;
        }
        return total;
    }

    // --- Generics method ---
    public static <T> List<T> repeat(T item, int times) {
        List<T> list = new ArrayList<>();
        for (int i = 0; i < times; i++) {
            list.add(item);
        }
        return list;
    }

    public static void main(String[] args) {
        // --- Strings ---
        String simple = "Hello, World!";
        String escaped = "tab\tnewline\nnull\0";
        String textBlock = """
                This is a text block
                with "quotes" inside
                and interpolation-like: %s
                """.formatted("value");
        char ch = 'A';

        // --- Numbers ---
        int dec = 42;
        long big = 1_234_567_890L;
        float f = 3.14f;
        double d = 2.71828;
        int hex = 0xFF;
        int oct = 077;
        int bin = 0b1010;

        // --- Booleans & Null ---
        boolean flag = true;
        boolean nope = false;
        Object nothing = null;

        // --- Type inference ---
        var inferred = "inferred";
        var list = new ArrayList<String>();

        // --- Control flow ---
        if (dec > 0) {
            System.out.println("positive");
        } else if (dec < 0) {
            System.out.println("negative");
        } else {
            System.out.println("zero");
        }

        // --- Switch expression (Java 14+) ---
        String result = switch (dec) {
            case 1, 2, 3 -> "small";
            case 42 -> "answer";
            default -> {
                yield "other";
            }
        };

        // --- Loops ---
        for (int i = 0; i < 10; i++) {
            if (i == 5) break;
            if (i == 3) continue;
        }

        for (String arg : args) {
            System.out.println(arg);
        }

        int j = 10;
        while (j > 0) {
            j--;
        }

        do {
            j++;
        } while (j < 5);

        // --- Operators ---
        int sum = 1 + 2;
        int diff = 5 - 3;
        int prod = 4 * 2;
        int quot = 10 / 3;
        int mod = 10 % 3;
        boolean logic = true && false || !true;
        int bitAnd = 0xFF & 0x0F;
        int ternary = sum > 0 ? sum : -sum;

        // --- Instanceof pattern matching (Java 16+) ---
        Object obj = "test";
        if (obj instanceof String s) {
            System.out.println(s.length());
        }

        // --- Exception handling ---
        try {
            throw new RuntimeException("oops");
        } catch (RuntimeException e) {
            System.out.println(e.getMessage());
        } finally {
            System.out.println("cleanup");
        }

        // --- Try with resources ---
        try (var resource = new java.io.StringReader("test")) {
            resource.read();
        } catch (Exception e) {
            e.printStackTrace();
        }

        // --- Lambda & Streams ---
        List<Integer> numbers = List.of(1, 2, 3, 4, 5);
        List<Integer> evens = numbers.stream()
            .filter(n -> n % 2 == 0)
            .map(n -> n * 2)
            .collect(Collectors.toList());

        // --- Method reference ---
        numbers.forEach(System.out::println);

        // --- Map ---
        Map<String, Integer> scores = new HashMap<>();
        scores.put("Alice", 95);
        scores.put("Bob", 87);
        scores.getOrDefault("Charlie", 0);

        // --- Optional ---
        Optional<String> opt = Optional.of("value");
        opt.ifPresent(System.out::println);
        String val = opt.orElse("default");

        // --- Assert ---
        assert dec == 42 : "Expected 42";

        // --- Synchronized block ---
        Object lock = new Object();
        synchronized (lock) {
            System.out.println("synchronized");
        }
    }
}
