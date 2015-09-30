# Recall

## Introduction

Recall is an esoteric programming language inspired by bin ops. It handles data using a global stack containing integer values. Values can also be stored in an unlimited number of global variables that are implicitly defined. There are no direct arithmetic operations in Recall, only logical bitwise operations. You have to implement arithmetic using macros.

## Reference

### Variables

Variables in Recall are all numerical strings that do not contain any zeros. Typing a variable name will pop a value from the stack and assign it to the variable. If the stack is empty, 0 is assigned. Here are a few examples of variable names:

Variable | Syntax
-------- | ------
1        | Valid
123      | Valid
1015     | Valid, although it might exceed the programs memory
2406     | Invalid, contains an operator (`0`)

Variables are non-volatile meaning that their content is preserved throughout the entire execution, they *can not* be destroyed (only overwritten). They're also global, so that they can be accessed in loops or macros.

### The `0` Operator and the Stack

The `0` operator is used to interact with the stack without altering values (like the letter operators). It is also the only operator with an (optional) argument:

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

Use the `!` operator to dump all variables and the current stack. This includes the offset, hex value and binary representation:

```
>  STACK(0):    E 00000045 00000000000000000000000001000101
-> VAR(4):        00000020 00000000000000000000000000100000
-> VAR(3):      e 00000065 00000000000000000000000001100101
-> VAR(2):        00000020 00000000000000000000000000100000
-> VAR(1):        00000001 00000000000000000000000000000001
```

### NOP

Use `.` whenever you need to separate something (like arguments and variable names).

## Examples

### Hello World

```
# Prints Hello World.

DM0Dg1                         # Obligatory var[1] = 1
01M202M303M404M505M606M707     # Set up 7 vars with ascending shifts.
04q                            # H
0706o80301o08q                 # e
0403o08o909X                   # l
09X                            # l
0902o01o11011X                 # o
06X                            #
011K06g07q                     # W
011X                           # o
0805o02q                       # r
09X                            # l
0803q                          # d
0601q                          # !
QoX                            # Macro: OR and print.
```

Output:

```
$ recall hello.rcl
Hello World!
```

### cat

```
# cat-like program

Y        # while (1) {
  x4     #   var[4] = getchar()
  04X    #   putchar(var[4])
  04z    #   if (var[4] = 0) break
y        # }
```

Output:

```
$ recall cat.rcl "Repeat"
Repeat
```

### Complain

```
# This program uppercases the input.

0DN0d1            # var[1] = 1
01MMMMM2          # var[2] = 32
Y                 # while (1) {
  x3              #   var[3] = getchar()
  03z             #   if (var[3] = 0) break
  020m4           #   var[4] = var[2]
  Y               #   while (1) {
    03KKKKKK      #     push var[3] and >> 6 times
	Z               #     if (pop()) break
	00m4            #     var[4] = 0
	0z              #     break
  y               #   }
  03              #   push(var[3])
  04              #   push(var[4])
  gX              #   putchar(var[3] ^ var[4])
y                 # }
```

Output:

```
$ recall complain.rcl "the case is a lie!"
THE CASE IS A LIE!
```

### Printables

```
# Prints a block of printable ASCII, linebreak at the half.

0DN0d1                     # var[1] = 1
01MMMMM01o2                # var[2] = 32
Y                          # while (1) {
  02X                      #   putchar(var[2])
  02q2                     #   var[2]++
  Y                        #   while (1) {
    0201MMM01MoMMMgZ       #     if (var[2] != 80) break
	r0z                    #     call r
  y                        #   }
  02qKKKKKKKZ              #   if (var[2] >= 127) break
y                          # }
r                          # call r

Q                          # Define macro q
  9                        # var[9] = pop()
  01.99                    # var[99] = var[1]
  Y                        # while (1) {
    09099g9                #   var[9] = var[9] ^ var[99]
    09099iZ                #   if (var[9]&var[99] != 0) break
    099M99                 #   var[99] = <<var[99]
  y                        # }
  09                       # push(var[9])

R                          # Define macro r
  01MMM01MoX               # putchar('\n')
```

Output:

```
$ recall printables.rcl
!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNO
PQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
```

