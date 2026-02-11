/* Block comment */
// Line comment

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

/* --- Preprocessor --- */
#define MAX_SIZE 100
#define SQUARE(x) ((x) * (x))

#ifdef DEBUG
#define LOG(msg) printf("DEBUG: %s\n", msg)
#else
#define LOG(msg)
#endif

#ifndef HEADER_GUARD
#define HEADER_GUARD
#endif

/* --- Types --- */
typedef unsigned long ulong;

typedef struct {
    char name[MAX_SIZE];
    int age;
    float score;
} Person;

typedef union {
    int i;
    float f;
    char c;
} Value;

typedef enum {
    RED = 0,
    GREEN = 1,
    BLUE = 2
} Color;

/* --- Constants --- */
static const int ZERO = 0;
const char *NULL_STR = NULL;

/* --- Function declarations --- */
int add(int a, int b);
void greet(const char *name);
static inline int max(int a, int b);
Person *create_person(const char *name, int age);

/* --- Function definitions --- */
int add(int a, int b) {
    return a + b;
}

void greet(const char *name) {
    printf("Hello, %s!\n", name);
}

static inline int max(int a, int b) {
    return (a > b) ? a : b;
}

Person *create_person(const char *name, int age) {
    Person *p = (Person *)malloc(sizeof(Person));
    if (p == NULL) {
        return NULL;
    }
    strncpy(p->name, name, MAX_SIZE - 1);
    p->name[MAX_SIZE - 1] = '\0';
    p->age = age;
    p->score = 0.0f;
    return p;
}

/* --- Main --- */
int main(int argc, char *argv[]) {
    /* Strings */
    char *str = "Hello, World!";
    char ch = 'A';
    char escaped[] = "tab\tnewline\nnull\0";

    /* Numbers */
    int dec = 42;
    int hex = 0xFF;
    int oct = 077;
    int bin = 0b1010;
    long big = 1234567890L;
    float f = 3.14f;
    double d = 2.71828;

    /* Booleans (C99) */
    bool flag = true;
    bool nope = false;

    /* Pointers */
    int *ptr = &dec;
    int **dbl_ptr = &ptr;
    void *void_ptr = NULL;

    /* Arrays */
    int arr[5] = {1, 2, 3, 4, 5};
    int matrix[2][3] = {{1, 2, 3}, {4, 5, 6}};

    /* Control flow */
    if (dec > 0) {
        printf("positive\n");
    } else if (dec < 0) {
        printf("negative\n");
    } else {
        printf("zero\n");
    }

    switch (arr[0]) {
        case 1:
            printf("one\n");
            break;
        case 2:
            printf("two\n");
            break;
        default:
            printf("other\n");
            break;
    }

    /* Loops */
    for (int i = 0; i < 5; i++) {
        if (i == 3) continue;
        printf("%d\n", arr[i]);
    }

    int j = 0;
    while (j < 10) {
        j++;
    }

    do {
        j--;
    } while (j > 0);

    /* Operators */
    int sum = 1 + 2;
    int diff = 5 - 3;
    int prod = 4 * 2;
    int quot = 10 / 3;
    int mod = 10 % 3;
    int neg = -sum;
    int bit_and = 0xFF & 0x0F;
    int bit_or = 0x10 | 0x01;
    int bit_xor = 0xFF ^ 0x0F;
    int bit_not = ~0;
    int lshift = 1 << 4;
    int rshift = 16 >> 2;
    bool logic = (1 > 0) && (2 > 1) || !(3 > 4);
    int ternary = (sum > 0) ? sum : -sum;
    int size = sizeof(Person);

    /* Struct usage */
    Person *alice = create_person("Alice", 30);
    printf("Name: %s, Age: %d\n", alice->name, alice->age);
    free(alice);

    /* Enum usage */
    Color c = RED;
    if (c == GREEN) {
        printf("green\n");
    }

    /* Goto (rare but valid) */
    goto end;
end:
    return 0;
}
