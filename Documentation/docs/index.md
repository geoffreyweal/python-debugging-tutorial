# Debugging in Python

This is a hands-on tutorial for learning how to **find and fix bugs in Python code**.

Every programmer, from beginner to expert, eventually runs into code that doesn't behave as expected—a variable holding the wrong value, a function raising a cryptic exception, or a program that silently produces incorrect output. Debugging is the systematic process of finding and fixing these issues, and it's a skill just as important as writing the code itself. 

This tutorial will help you build the skills to diagnose problems quickly and confidently, turning debugging from a frustrating chore into a methodical part of the development process.

## What kinds of bugs?

A useful way to categorise bugs is when and how they reveal themselves:

1. Syntax errors. Caught before the code even runs — invalid Python grammar (missing colons, unmatched parentheses, bad indentation). Python's parser flags these immediately with a `SyntaxError`.

2. Runtime errors (exceptions). The code is syntactically valid but crashes during execution — `TypeError`, `ValueError`, `IndexError`, `KeyError`, `AttributeError`, etc. These are usually the easiest to debug because Python gives you a traceback pointing to the exact line.

3. Logic errors (semantic bugs)
The most insidious category — the program runs to completion without any error, but produces the wrong result. No traceback, no crash, just silently incorrect behavior (e.g., an off-by-one loop, a flipped comparison operator, wrong operator precedence).

This training will focus on 1-3. There are other bugs you may need to be aware of, however. These include performance bugs, concurrency bugs, and memory leaks and other resource bugs.

Even as AI coding assistants become adept at writing and even fixing code, strong debugging skills remain indispensable—arguably more so than ever. AI-generated code can look plausible while harboring subtle logic errors or bugs that only surface under specific runtime conditions the model never considered. Without the ability to reason about program state, and methodically isolate a failure, a developer is left overtrusting the AI's output, leading to a cycle of superficial patches that mask the real problem. Debugging skill is also what lets you evaluate AI suggestions critically: knowing how to set a breakpoint, inspect a variable, or write a targeted test gives you the means to verify a fix rather than take it on faith.

## What you will learn

By the end of this tutorial you will be able to:

1. **Read a traceback** and work out where and why your program crashed.
2. Use **`print()` debugging** and the **`logging`** module — quick throwaway diagnostics, and the same idea made permanent and switchable.
3. Step through your code line-by-line with the built-in **Python debugger (`pdb`)** and `breakpoint()`.
4. Use the **VS Code visual debugger** to set breakpoints, inspect variables, and watch expressions.
5. Recognise **common Python bugs** (mutable default arguments, off-by-one errors, shadowed names, and more).

## How this tutorial works

Each section introduces one technique, shows a worked example, and ends with a short exercise. The [Exercises](exercises.md) page collects larger, realistic buggy programs for you to fix using everything you've learned.

!!! tip "The golden rule of debugging"
    **Don't guess — observe.** Every technique in this tutorial is a different way of *observing* what your program is actually doing, so you can compare it to what you *think* it should be doing.

## A systematic debugging strategy

Whenever something goes wrong, work through these steps:

1. **Reproduce the bug.** Find the smallest input that reliably triggers it.
2. **Read the error message.** Tracebacks tell you the file, the line, and the kind of error — start there.
3. **Form a hypothesis.** "I think `total` is wrong because the loop skips the last item."
4. **Test the hypothesis.** Add a print, a log line, or a breakpoint and *look*.
5. **Fix one thing at a time**, then re-run. If you change five things at once, you won't know which one mattered.
6. **Add a test** (or at least a comment) so the bug can't sneak back in.

Ready? Head to [Setup](setup.md) to get your environment ready.
