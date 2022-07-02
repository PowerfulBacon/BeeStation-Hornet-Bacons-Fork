# DMScript

This is an interpreted scripting language designed to be able to be directly translated straight into DreamMaker.
The aim of this is to support basic features of DM, so you can code without having to restart the game.
Once you have completed your code prototypes, you can translate it directly into byond by just copy and pasting the scripting code.

## Interface

You can call DMScript functions from inside regular dreammaker code files by calling
```dm
DmScriptCall("function_name", args)
```
This will do nothing until you create the function in dmscript, and once you do it will run the interpreter and execute your
script.

You can call regular .DM functions from inside dmscript scripts. This is done by calling the function normally,
as if you would in .DM. (Internally this executes call())

## Precidence

Not sure about the order of operations in DMScript, so I'm just going to use the C# precidence since its actually quite well defined.
https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/operators/

## Supported Syntax

### Comments

Lines starting with // will be considered a comment and will not be compiled.

```
//Comment text
```

Block comments are also supported

```
/*
 * hello
 */
```

### Proc Definitions

A proc defined in DMscript allows it to be called from inside DMscript or DM.
A proc definition can be either global or on a specific type.

### Proc Calls

The proc name followed by brackets containing the arguments will trigger a proc call.
If the specified function is defined inside DMscript, then that will be called, otherwise the proc will be called in byond.
Proc calls can be either global or targetted at a specific instance.

**..() is not currently supported**

```
proc_name(argument1, argument2, argument3)
```

### Types

Byond syntax types are ignored but will still compile and run like normal.
Adding types will lead to better code when converting DMscript into DM so should still be used.

## Unsupported Syntax

Defines are not supported.

## Compiler

When a function is modified, it is compiled into bytecode. This is then interpreted by some code in byond.

0x01 - Function call
