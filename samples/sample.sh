#!/bin/bash

# Single line comment

# --- Variables ---
NAME="world"
readonly CONSTANT="immutable"
local_var="local"
export EXPORTED_VAR="exported"

# --- Strings ---
single='single quoted string'
double="Hello, ${NAME}!"
raw_string=$'escape\tsequence\n'
heredoc_str=$(cat <<'EOF'
This is a heredoc
with no interpolation
EOF
)
heredoc_interp=$(cat <<EOF
Hello, ${NAME}
EOF
)

# --- Numbers ---
integer=42
hex=0xFF
octal=077

# --- Conditionals ---
if [ "$NAME" = "world" ]; then
    echo "Hello!"
elif [ "$NAME" = "earth" ]; then
    echo "Hi!"
else
    echo "Unknown"
fi

# --- Case ---
case "$NAME" in
    "world")
        echo "Known"
        ;;
    "earth"|"mars")
        echo "Planet"
        ;;
    *)
        echo "Unknown"
        ;;
esac

# --- Loops ---
for i in 1 2 3 4 5; do
    echo "$i"
done

for ((i = 0; i < 10; i++)); do
    echo "$i"
done

while [ "$i" -gt 0 ]; do
    i=$((i - 1))
done

until [ "$i" -ge 10 ]; do
    i=$((i + 1))
done

select opt in "Option1" "Option2" "Quit"; do
    case "$opt" in
        "Quit") break ;;
        *) echo "Selected: $opt" ;;
    esac
done

# --- Functions ---
function greet() {
    local greeting="Hello"
    echo "${greeting}, $1!"
    return 0
}

say_hi() {
    echo "Hi, $1!"
}

greet "World"
say_hi "Earth"

# --- Arrays ---
declare -a fruits=("apple" "banana" "cherry")
echo "${fruits[0]}"
echo "${#fruits[@]}"

declare -A colors
colors[red]="#FF0000"
colors[green]="#00FF00"

# --- Command substitution ---
current_date=$(date +%Y-%m-%d)
files=`ls -la`

# --- Process substitution ---
diff <(ls dir1) <(ls dir2)

# --- Arithmetic ---
result=$((2 + 3 * 4))
((count++))

# --- Redirects ---
echo "output" > /tmp/out.txt
echo "append" >> /tmp/out.txt
cat < /tmp/out.txt
command 2>&1

# --- Pipes ---
ls -la | grep ".sh" | wc -l

# --- Test operators ---
[ -f "/etc/passwd" ] && echo "exists"
[[ "$NAME" =~ ^w.*d$ ]] && echo "matches"
[ -d "/tmp" -a -w "/tmp" ] && echo "writable dir"

# --- Special variables ---
echo "Script: $0"
echo "Args: $@"
echo "Count: $#"
echo "Exit: $?"
echo "PID: $$"

# --- Brace expansion ---
echo {1..5}
echo {a..z}

# --- Subshell ---
(cd /tmp && ls)

# --- Declare/typeset ---
declare -i number=42
declare -r readonly_var="can't change"
typeset -l lowercase="HELLO"
unset NAME
