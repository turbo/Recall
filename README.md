# Recall

## Introduction

Recall is an esoteric programming language. It handles data using a global stack containing unsigned 8bit values. Values can also be stored in an unlimited number of global variables that are implicitely defined.

## Reference

### Variables

You can not push or pop values directly to the stack (except when using the I/O functions). Variables in Recall are all numerical strings that do not contain any zeros. Here are a few examples of variable names:

Variable | Syntax
-------- | ------
1        | Valid
123      | Valid
4263532  | Valid, although it might exceed the programs memory
2406     | Invalid, contains an operator (`0`)

Variables are non-volatile meaning that their content is preserved though the entire execution, they *can not* be destroyed (only emptied). They're also global, so that they can be accessed in loops or subs.

### The `0` Operator and the Stack

The `0` operator is used to interact with the stack without altering values (like the letter operators). It is also the only operator with an (optional) argument:

Usage  | Purpose
------ | -------
0      | Pushes an empty byte onto the stack.
0<var> | Pushes the content of <var> onto the stack. Preserves the value in <var>.
<var>  | Pops the stack and writes the value to <var>.

### Comments

Comments start with `#` and end with `#`. Technically, all non-operators are ignored, but this is the safe way to comment.

### Loops and Subs

Loops in Recall are infinite and must be escaped from using the `z` (or `Z`) operator. Loops start with `Y` and end with `y`:

```
Y # Begin loop #
  #
    do things
  #
  z # pop and exit when 0 #
  Z # pop and exit when not 0 #
y
```

Note that both exit operators pop the top value so you have to push something back or the loop is going to delete the whole stack and stall :-).

Another form of flow control are subs (parameterless functions). They are defined after the main code. Each sub ends at the header of the next sub or at the EOF. Each **uppercase** character from `Q` to `W` can hold one sub. Each sub is called from the main code by the **lowercase** letter. Example:

```
# main code (read byte from input) #
xq

# Sub Q (write byte to output) #
QX
```

Loops can be nested. Subs can *not* be recursive (well they can - no implementation stricly forbids this, but the limit before SO is defined by the compiler).

### Operators

There are *only* bitwise operators. Yeah, that's right, *you* have to implement arithmetics. Every operator takes to input values, `a` and `b`. What those are depends on wether the operator is lower- or uppercase. 

**UPPERCASE**

Pops `<val>` from the stack. (Means only *one* pop is performed.)

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

OP | Operation | Logical Return Value
-- | --------- | --------------------
A  | -         | `0`
B  | NOR       | `~(a|b)`
C  | NIMPL     | `(~a) & b`
D  | NOT       | `~a`
E  | NIMPL     | `a & (~b)`
F  | NOT       | `~b`
G  | XOR       | `a^b`
H  | NAND      | `~(a&b)`
I  | AND       | `a&b`
J  | NXOR      | `~(a^b)`
K  | -         | `b`
L  | IMPL      | `~(a & (~b))`
M  | -         | `a`
N  | IMPL      | `~(b & (~a))`
O  | OR        | `a|b`
P  | -         | `255`

### IO

OP | Purpose
-- | -------
x  | Read a single byte (ASCII) from the input
X  | Pop and write as ASCII char to output

You have to create your own input handler. I suggest you break on LF and ignore CR - but that's up to you.

### Debugging

Use the `!` operator to dump all variables and the current stack. This includes the offset, hex value and binary representation.

### NOP

Use `.` whenever you need to separate something (like arguments and variable names).

## Examples

Is Recall Turin complete? Let me answer this with a Brainfuck interpreter written in Recall (which is probably the slowest on the planet):

```
DC505M22022M32032M606M42042M707M92092M4405022o032o06o042o07o092o044o1305022
o06o042o092o52052q.q2305022o06o07o93093q.q5403206o07o14014q.q6403206o042o07
o24024q.q74Yx34034z03MMMMMMMM034o3yY030401r3.4.101zyY040301r4.3.101zY01052g
Z02Z040301052023s4.3.10zyY01023gZ02z030401023052s3.4.10zyY01093gZ02q20zyY01
054gZ02u20zyY01014gZx20zyY01064gZ02X0zyY01024gZ03304302r33.43.20zyY01074gZ0
4303302r43.33.20zyyQ6205.8Y06208g6206208iZ08M808013izy062U7205.9Y07209g7207
209iz09M909013izy072R53.63.82063MMMMMMMM053o63082013i53082KKKKKKKK820530630
82S84.94.12.73.83t012073083TY083073012r83.73.12012084gzY012094gZt0zyy
```






