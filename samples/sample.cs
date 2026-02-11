// Line comment
/* Block comment */

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SampleNamespace
{
    // --- Enums ---
    public enum Color
    {
        Red,
        Green,
        Blue
    }

    // --- Interfaces ---
    public interface IGreetable
    {
        string Greet();
    }

    // --- Abstract class ---
    public abstract class Animal
    {
        public abstract string Speak();
        public virtual string Name { get; set; } = "Unknown";
    }

    // --- Struct ---
    public struct Point
    {
        public double X { get; init; }
        public double Y { get; init; }

        public double Distance(Point other)
        {
            return Math.Sqrt(Math.Pow(X - other.X, 2) + Math.Pow(Y - other.Y, 2));
        }
    }

    // --- Record ---
    public record Person(string Name, int Age);

    // --- Sealed class ---
    public sealed class Dog : Animal, IGreetable
    {
        public override string Speak() => "Woof!";

        public string Greet() => $"I'm {Name}";
    }

    // --- Generic class ---
    public class Container<T> where T : class, new()
    {
        private readonly List<T> _items = new();

        public void Add(T item) => _items.Add(item);
        public T? Get(int index) => index < _items.Count ? _items[index] : null;
        public int Count => _items.Count;
    }

    // --- Static class ---
    public static class MathHelper
    {
        public const double Pi = 3.14159;
        public static readonly int MaxValue = int.MaxValue;

        public static int Add(int a, int b) => a + b;
        public static async Task<int> AddAsync(int a, int b)
        {
            await Task.Delay(100);
            return a + b;
        }
    }

    // --- Main class ---
    public class Program
    {
        // --- Delegate & Event ---
        public delegate void MessageHandler(string message);
        public event MessageHandler? OnMessage;

        public static void Main(string[] args)
        {
            // --- Strings ---
            string simple = "Hello, World!";
            string interpolated = $"Result: {1 + 2}";
            string verbatim = @"C:\Users\test\file.txt";
            string raw = """
                Raw string literal
                with "quotes" inside
                """;
            char ch = 'A';
            string escaped = "tab\tnewline\n";

            // --- Numbers ---
            int integer = 42;
            long big = 1234567890L;
            float f = 3.14f;
            double d = 2.71828;
            decimal money = 19.99m;
            int hex = 0xFF;
            int bin = 0b1010;

            // --- Booleans & Null ---
            bool flag = true;
            bool nope = false;
            string? nullable = null;

            // --- var ---
            var inferred = "inferred type";

            // --- Control flow ---
            if (integer > 0)
            {
                Console.WriteLine("positive");
            }
            else if (integer < 0)
            {
                Console.WriteLine("negative");
            }
            else
            {
                Console.WriteLine("zero");
            }

            switch (integer)
            {
                case 1:
                    Console.WriteLine("one");
                    break;
                case 2:
                    Console.WriteLine("two");
                    break;
                default:
                    Console.WriteLine("other");
                    break;
            }

            // --- Switch expression ---
            string result = integer switch
            {
                > 0 => "positive",
                < 0 => "negative",
                _ => "zero"
            };

            // --- Loops ---
            for (int i = 0; i < 10; i++)
            {
                if (i == 5) break;
                if (i == 3) continue;
            }

            foreach (var item in new[] { 1, 2, 3 })
            {
                Console.WriteLine(item);
            }

            int j = 10;
            while (j > 0)
            {
                j--;
            }

            do
            {
                j++;
            } while (j < 5);

            // --- Operators ---
            int sum = 1 + 2;
            bool logic = true && false || !true;
            int ternary = sum > 0 ? sum : -sum;
            string coalesce = nullable ?? "default";
            int? nullableInt = null;
            int safe = nullableInt ?? 0;

            // --- Type checks ---
            object obj = "test";
            if (obj is string s)
            {
                Console.WriteLine(s.Length);
            }
            var cast = obj as string;
            var typeOf = typeof(string);
            var sizeOf = sizeof(int);

            // --- Exception handling ---
            try
            {
                throw new InvalidOperationException("oops");
            }
            catch (InvalidOperationException ex) when (ex.Message.Contains("oops"))
            {
                Console.WriteLine(ex.Message);
            }
            catch (Exception)
            {
                Console.WriteLine("unexpected");
            }
            finally
            {
                Console.WriteLine("cleanup");
            }

            // --- Pattern matching ---
            object value = 42;
            if (value is int n and > 0)
            {
                Console.WriteLine($"Positive int: {n}");
            }

            // --- LINQ ---
            var numbers = new List<int> { 1, 2, 3, 4, 5 };
            var evens = from num in numbers
                        where num % 2 == 0
                        orderby num descending
                        select num;

            // --- Lambda ---
            Func<int, int> square = x => x * x;
            Action<string> print = msg => Console.WriteLine(msg);

            // --- Async/Await ---
            RunAsync().Wait();

            // --- Record usage ---
            var person = new Person("Alice", 30);
            var older = person with { Age = 31 };

            // --- Struct usage ---
            var p1 = new Point { X = 1.0, Y = 2.0 };
            var p2 = new Point { X = 4.0, Y = 6.0 };
            Console.WriteLine(p1.Distance(p2));

            // --- Using/lock ---
            lock (obj)
            {
                Console.WriteLine("synchronized");
            }

            // --- Goto ---
            goto end;
        end:
            Console.WriteLine("done");
        }

        private static async Task RunAsync()
        {
            var result = await MathHelper.AddAsync(1, 2);
            Console.WriteLine(result);
        }

        // --- Yield ---
        public static IEnumerable<int> Fibonacci()
        {
            int a = 0, b = 1;
            while (true)
            {
                yield return a;
                (a, b) = (b, a + b);
            }
        }

        // --- Operator overloading ---
        public static implicit operator string(Program p) => "Program";
        public static explicit operator int(Program p) => 0;
    }
}
