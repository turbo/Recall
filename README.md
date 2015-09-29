# Recall

## Introduction

Recall is an esoteric programming language. It handles data using a global stack containing unsigned 8bit values. Values can also be stored in an unlimited number of global variables that are implicitely defined.

## Reference

### Variables

You can not push or pop values directly to the stack (except when using the I/O functions). Variables in Recall are all numerical strings that do not contain any zeros. Here are a few examples of variable names:

Variable  | Syntax
------------- | -------------
1  | Valid
123  | Valid
4263532 | Valid*
2406 | Invalid, contains an operator (`0`)

*\*(although it might exceed the programs memory - depends on implementation)*
