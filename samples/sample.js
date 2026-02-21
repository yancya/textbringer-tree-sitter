// Line comment
// 日本語のコメント
/* Block comment */
/** JSDoc comment */

// --- Variables & Constants ---
const PI = 3.14159;
let count = 0;
var legacy = "old style";

// --- Strings ---
const greeting = "こんにちは世界";
const simple = "double quoted";
const single = 'single quoted';
const template = `Hello, ${count + 1} world!`;
const multiline = `
  Multi-line
  template string
`;
const escaped = "tab\tnewline\nnull\0";
const regex = /pattern[a-z]+/gi;

// --- Numbers ---
const integer = 42;
const float = 3.14;
const negative = -17;
const hex = 0xFF;
const octal = 0o77;
const binary = 0b1010;
const bigint = 9007199254740991n;
const scientific = 1.5e10;
const separator = 1_000_000;

// --- Booleans & Special ---
const yes = true;
const no = false;
const nothing = null;
const notDefined = undefined;

// --- Functions ---
function greet(name) {
    return `Hello, ${name}!`;
}

function* fibonacci() {
    let a = 0, b = 1;
    while (true) {
        yield a;
        [a, b] = [b, a + b];
    }
}

async function fetchData(url) {
    const response = await fetch(url);
    return await response.json();
}

const arrow = (x) => x * 2;
const arrowMultiline = (a, b) => {
    const sum = a + b;
    return sum;
};

// --- Classes ---
class Animal {
    #name;
    static count = 0;

    constructor(name) {
        this.#name = name;
        Animal.count++;
    }

    get name() {
        return this.#name;
    }

    set name(value) {
        this.#name = value;
    }

    speak() {
        return `${this.#name} makes a sound`;
    }

    toString() {
        return `Animal(${this.#name})`;
    }
}

class Dog extends Animal {
    #breed;

    constructor(name, breed) {
        super(name);
        this.#breed = breed;
    }

    speak() {
        return `${this.name} barks!`;
    }
}

// --- Objects & Arrays ---
const obj = {
    key: "value",
    nested: {
        a: 1,
        b: [2, 3, 4],
    },
    method() {
        return this.key;
    },
    get computed() {
        return this.key.toUpperCase();
    },
};

const arr = [1, 2, 3, ...obj.nested.b];
const { key, nested: { a } } = obj;
const [first, ...rest] = arr;

// --- Control flow ---
if (count > 0) {
    console.log("positive");
} else if (count < 0) {
    console.log("negative");
} else {
    console.log("zero");
}

switch (count) {
    case 0:
        console.log("zero");
        break;
    case 1:
        console.log("one");
        break;
    default:
        console.log("other");
        break;
}

// --- Loops ---
for (let i = 0; i < 10; i++) {
    if (i === 5) break;
    if (i === 3) continue;
}

for (const item of arr) {
    console.log(item);
}

for (const key in obj) {
    console.log(key, obj[key]);
}

let j = 10;
while (j > 0) {
    j--;
}

do {
    j++;
} while (j < 5);

// --- Operators ---
const sum = 1 + 2;
const diff = 5 - 3;
const prod = 4 * 2;
const quot = 10 / 3;
const mod = 10 % 3;
const exp = 2 ** 8;
const logic = true && false || !null;
const nullCoalesce = nothing ?? "default";
const optionalChain = obj?.nested?.a;
const ternary = count > 0 ? "yes" : "no";
const typeCheck = typeof count;
const instanceCheck = obj instanceof Object;
void 0;
delete obj.key;

// --- Exception handling ---
try {
    throw new Error("oops");
} catch (err) {
    console.error(err.message);
} finally {
    console.log("cleanup");
}

// --- Promises ---
const promise = new Promise((resolve, reject) => {
    setTimeout(() => resolve("done"), 1000);
});

promise
    .then(result => console.log(result))
    .catch(err => console.error(err))
    .finally(() => console.log("finished"));

// --- Modules ---
import { readFile } from 'fs';
import * as path from 'path';
import defaultExport from 'module';

export const exported = "value";
export default class ExportedClass {}
export { greet, arrow as doubler };

// --- Destructuring & Spread ---
const cloned = { ...obj, extra: true };
const merged = [...arr, 5, 6];

// --- Optional chaining & nullish ---
const safe = obj?.nested?.missing ?? "fallback";

// --- Tagged template ---
function tag(strings, ...values) {
    return strings.join("") + values.join("");
}
const tagged = tag`Hello ${count} world`;

// --- Symbol ---
const sym = Symbol("unique");
const iter = Symbol.iterator;

// --- WeakRef & FinalizationRegistry ---
const ref = new WeakRef(obj);
const registry = new FinalizationRegistry(value => {
    console.log(`Collected: ${value}`);
});

// --- Async iteration ---
async function* asyncGenerator() {
    yield 1;
    yield 2;
    yield 3;
}

// --- Labeled statement ---
outer:
for (let i = 0; i < 3; i++) {
    for (let j = 0; j < 3; j++) {
        if (j === 1) continue outer;
        if (i === 2) break outer;
    }
}

// --- with (deprecated but valid) ---
with (Math) {
    const r = random();
}

// --- debugger ---
debugger;

// --- arguments ---
function oldStyle() {
    return arguments.length;
}

// --- new.target ---
function Constructable() {
    if (new.target) {
        this.created = true;
    }
}
