# Recall

## Introduction

Recall is an esoteric programming language inspired by bin ops. It handles data using a global stack containing integer values. Values can also be stored in an unlimited number of global variables that are implicitly defined. There are no direct arithmetic operations in Recall, only logical bitwise operations. You have to implement arithmetic using macros.

## Getting Started

### Using the online interpreter

A asm.js compliant, fast interpreter is here: [minxomat.github.io/Recall](http://minxomat.github.io/Recall). The interpreter is `recall.min.js` and the above page always loads the latest implementation from this repository (or branch) here. It also generates perma-links so you can share programs anywhere else.

### Running Recall locally

Just clone this repo here or download `recall.min.js` and then run it with node.js. You can supply the code and stdin through the console. This way you can read files that contain linefeeds:

```
echo A 'cat' example. | node recall.min.js "Yx101X01zy"
```

## Reference

### Variables

Variables in Recall are all numerical strings that do not contain any zeros. Typing a variable name will pop a value from the stack and assign it to the variable. If the stack is empty, 0 is assigned. Here are a few examples of variable names:

Variable | Syntax
-------- | ------
1        | Valid
123      | Valid
1115     | Valid, although it might exceed the programs memory
2406     | Invalid, contains an operator (`0`)

Variables are non-volatile meaning that their content is preserved throughout the entire execution, they *can not* be destroyed (only overwritten). They're also global, so that they can be accessed in loops or macros.

### The `0` Operator and the Stack

Usage    | Purpose
-------- | -------
`0`      | Pushes an empty byte onto the stack.
`0<var>` | Pushes the content of `<var>` onto the stack.
`<var>`  | Pops the stack and writes the value to `<var>`.

### Comments

Comments start with `#` and end at the end of the line (which must be `\n` - CRs are ignored). Technically, all non-operators are ignored, but this is the safe way to comment.

### Loops and Macros

Loops in Recall are infinite and must be escaped from using the `z` (or `Z`) operator. Loops start with `Y` and end with `y`:

```
Y        # Begin loop
         # do things
  z      # pop and exit when 0
  Z      # pop and exit when not 0
y
```

Note that both exit operators pop the top value so you have to push something back or the loop is going to delete the whole stack and stall :-).

Another form of flow control are macros (parameterless functions). They are defined after the main code. Each macro ends at the header of the next macro or at the EOF. Each **uppercase** character from `Q` to `W` can hold one macro. Each macro is called from the main code by the **lowercase** letter. Example:

```
# main code (read byte from input)
xq

# Sub Q (write byte to output)
QX
```

Loops can be nested. Subs should *not* be recursive (well they can - no implementation strictly forbids this, but the limit before SO is undefined).

### Operators

There are *only* bitwise operators. Every operator takes to input values, `a` and `b`. What those are depends on wether the operator is lower- or uppercase. 

**UPPERCASE**

Pops `<val>` from the stack. (Only *one* pop is performed.)

Argument | Value
-------- | -----
a        | `<val>` shifted left
b        | `<val>` shifted right

**lowercase**

Pops two values from the stack.

Argument | Value
-------- | -----
a        | Result from first POP
b        | Result from second POP

The following operators are available. Their result is pushed onto the stack.

OP  | Operation | Logical Return Value | OP  | Operation | Logical Return Value
--- | --------- | -------------------- | --- | --------- | --------------------
A   | /         | `0`                  | I   | AND       | `a&b`  
B   | NOR       | `~(a|b)`             | J   | NXOR      | `~(a^b)`     
C   | NIMPL     | `(~a) & b`           | K   | /         | `b`          
D   | NOT       | `~a`                 | L   | IMPL      | `~(a & (~b))`
E   | NIMPL     | `a & (~b)`           | M   | /         | `a`          
F   | NOT       | `~b`                 | N   | IMPL      | `~(b & (~a))`
G   | XOR       | `a^b`                | O   | OR        | `a|b`        
H   | NAND      | `~(a&b)`             | P   | /         | `255`        



### IO

OP | Purpose
--- | -------
x  | Read a single byte (ASCII) from the input
X  | Pop and write as ASCII char to output

You have to create your own input handler. I suggest you break on LF and ignore CR - but that's up to you.

### Debugging

Use the `!` operator to dump all variables and the current stack.

### NOP

Use `.` whenever you need to separate something (like arguments and variable names).
