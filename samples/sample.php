<?php
// Line comment
# Hash comment
/* Block comment */
/**
 * PHPDoc comment
 * @param string $name
 * @return string
 */

declare(strict_types=1);

namespace App\Sample;

use App\Models\User;
use App\Services\{AuthService, MailService};
use function array_map;

// --- Constants ---
const APP_VERSION = '1.0.0';
define('MAX_RETRIES', 3);

// --- Interface ---
interface Greeter
{
    public function greet(string $name): string;
}

// --- Trait ---
trait Loggable
{
    private function log(string $message): void
    {
        echo "[LOG] {$message}\n";
    }
}

// --- Abstract class ---
abstract class Animal
{
    public function __construct(
        protected readonly string $name,
        protected int $age = 0,
    ) {}

    abstract public function speak(): string;

    public function __toString(): string
    {
        return "{$this->name}: {$this->speak()}";
    }
}

// --- Enum (PHP 8.1+) ---
enum Color: string
{
    case Red = 'red';
    case Green = 'green';
    case Blue = 'blue';

    public function label(): string
    {
        return match($this) {
            self::Red => 'Red Color',
            self::Green => 'Green Color',
            self::Blue => 'Blue Color',
        };
    }
}

// --- Class ---
class Dog extends Animal implements Greeter
{
    use Loggable;

    private static int $count = 0;

    public function __construct(
        string $name,
        int $age,
        private readonly string $breed = 'Mixed',
    ) {
        parent::__construct($name, $age);
        self::$count++;
    }

    public function speak(): string
    {
        return 'Woof!';
    }

    public function greet(string $name): string
    {
        $this->log("Greeting {$name}");
        return "Woof! Hello, {$name}!";
    }

    public static function getCount(): int
    {
        return static::$count;
    }

    public function __destruct()
    {
        self::$count--;
    }
}

// --- Strings ---
$single = 'single quoted';
$double = "Hello, {$_SERVER['SERVER_NAME']}!";
$heredoc = <<<EOT
This is a heredoc
with variable: $single
and expression: {$_SERVER['SERVER_NAME']}
EOT;
$nowdoc = <<<'EOT'
This is a nowdoc
no interpolation: $single
EOT;
$escaped = "tab\tnewline\n\\backslash";
$shell = `echo hello`;

// --- Numbers ---
$integer = 42;
$negative = -17;
$hex = 0xFF;
$octal = 0o77;
$binary = 0b1010;
$float = 3.14;
$scientific = 1.5e10;
$separator = 1_000_000;

// --- Booleans & Null ---
$yes = true;
$no = false;
$nothing = null;

// --- Arrays ---
$indexed = [1, 2, 3, 4, 5];
$assoc = [
    'name' => 'Alice',
    'age' => 30,
    'active' => true,
];
$nested = [
    'users' => [
        ['id' => 1, 'name' => 'Alice'],
        ['id' => 2, 'name' => 'Bob'],
    ],
];

// --- Control flow ---
if ($integer > 0) {
    echo "positive\n";
} elseif ($integer < 0) {
    echo "negative\n";
} else {
    echo "zero\n";
}

// --- Match expression (PHP 8.0+) ---
$result = match($integer) {
    0 => 'zero',
    1, 2, 3 => 'small',
    default => 'other',
};

// --- Switch ---
switch ($integer) {
    case 1:
        echo "one\n";
        break;
    case 2:
        echo "two\n";
        break;
    default:
        echo "other\n";
        break;
}

// --- Loops ---
for ($i = 0; $i < 10; $i++) {
    if ($i === 5) break;
    if ($i === 3) continue;
}

foreach ($indexed as $value) {
    echo "{$value}\n";
}

foreach ($assoc as $key => $value) {
    echo "{$key}: {$value}\n";
}

$j = 10;
while ($j > 0) {
    $j--;
}

do {
    $j++;
} while ($j < 5);

// --- Functions ---
function add(int $a, int $b): int
{
    return $a + $b;
}

function greetPerson(string $name, string $greeting = 'Hello'): string
{
    return "{$greeting}, {$name}!";
}

// --- Arrow function (PHP 7.4+) ---
$double = fn(int $x): int => $x * 2;

// --- Closure ---
$multiplier = 3;
$multiply = function (int $x) use ($multiplier): int {
    return $x * $multiplier;
};

// --- Variadic ---
function sum(int ...$numbers): int
{
    return array_sum($numbers);
}

// --- Named arguments (PHP 8.0+) ---
$greeting = greetPerson(name: 'World', greeting: 'Hi');

// --- Type declarations ---
function process(int|string $value, ?array $options = null): string|false
{
    if (is_int($value)) {
        return (string) $value;
    }
    return $value ?: false;
}

// --- Operators ---
$sum = 1 + 2;
$concat = 'Hello' . ' ' . 'World';
$spaceship = 1 <=> 2;
$nullCoalesce = $nothing ?? 'default';
$nullAssign = $nothing ??= 'assigned';
$spread = [...$indexed, 6, 7];

// --- Exception handling ---
try {
    throw new \RuntimeException('Something went wrong');
} catch (\RuntimeException $e) {
    echo "Caught: {$e->getMessage()}\n";
} catch (\Exception $e) {
    echo "General: {$e->getMessage()}\n";
} finally {
    echo "cleanup\n";
}

// --- Instanceof ---
$dog = new Dog('Rex', 5, 'Labrador');
if ($dog instanceof Animal) {
    echo $dog->speak() . "\n";
}

// --- Clone ---
$clone = clone $dog;

// --- Goto ---
goto end;
echo "skipped\n";
end:
echo "done\n";

// --- Yield ---
function fibonacci(): \Generator
{
    $a = 0;
    $b = 1;
    while (true) {
        yield $a;
        [$a, $b] = [$b, $a + $b];
    }
}

// --- Include/Require ---
// include 'header.php';
// include_once 'config.php';
// require 'functions.php';
// require_once 'autoload.php';

// --- Global ---
function useGlobal(): void
{
    global $integer;
    echo $integer;
}

// --- Print/Echo ---
echo "Hello\n";
print("World\n");
