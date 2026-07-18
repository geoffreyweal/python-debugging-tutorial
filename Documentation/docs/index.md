# Debugging in Python

Welcome! This is a hands-on tutorial for learning how to **find and fix bugs in Python code**.

Debugging is one of the most important skills a programmer can have — most of the time you spend "programming" is actually spent working out why your code isn't doing what you expected. The good news is that debugging is a learnable, systematic skill, not a magic talent.

## What you will learn

By the end of this tutorial you will be able to:

1. **Read a traceback** and work out where and why your program crashed.
2. Use **print debugging** effectively (and know its limits).
3. Use the **`logging`** module as a better, permanent alternative to prints.
4. Step through your code line-by-line with the built-in **Python debugger (`pdb`)** and `breakpoint()`.
5. Use the **VS Code visual debugger** to set breakpoints, inspect variables, and watch expressions.
6. Recognise **common Python bugs** (mutable default arguments, off-by-one errors, shadowed names, and more).

## How this tutorial works

Each section introduces one technique, shows a worked example, and ends with a short exercise. The [Exercises](exercises.md) page collects larger, realistic buggy programs for you to fix using everything you've learned.

!!! tip "The golden rule of debugging"
    **Don't guess — observe.** Every technique in this tutorial is a different way of *observing* what your program is actually doing, so you can compare it to what you *think* it should be doing. The bug lives in the gap between those two.

## A systematic debugging strategy

Whenever something goes wrong, work through these steps:

1. **Reproduce the bug.** Find the smallest input that reliably triggers it.
2. **Read the error message.** Tracebacks tell you the file, the line, and the kind of error — start there.
3. **Form a hypothesis.** "I think `total` is wrong because the loop skips the last item."
4. **Test the hypothesis.** Add a print, a log line, or a breakpoint and *look*.
5. **Fix one thing at a time**, then re-run. If you change five things at once, you won't know which one mattered.
6. **Add a test** (or at least a comment) so the bug can't sneak back in.

Ready? Head to [Setup](setup.md) to get your environment ready.
