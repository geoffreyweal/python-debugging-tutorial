# 2. Print debugging

The simplest debugging technique: put `print()` statements in your code to see what's actually happening. Everyone does it, it works everywhere, and done *well* it's genuinely effective. Done badly, it produces a wall of unlabelled numbers you can't interpret.

## A buggy example

This function is supposed to count how many words appear in a sentence more than once — but it always returns `0`:

```python title="repeats.py"
def count_repeated_words(sentence):
    words = sentence.split()
    counts = {}
    for word in words:
        counts[word] = counts.get(word, 0) + 1

    repeated = 0
    for word, count in counts.items():
        if count > 2:
            repeated += 1
    return repeated

print(count_repeated_words("the cat sat on the mat"))  # expected 1 ("the"), got 0
```

No crash, no traceback — the logic is just wrong somewhere. Time to observe.

## Print the right things, the right way

**Rule 1 — label every print.** A bare `print(count)` printing `2` tells you nothing when you have five prints. Say *what* and *where*:

```python
print(f"counts after loop: {counts}")
```

**Rule 2 — use `!r` or `repr()` to see the true value.** `print(name)` shows `Alice` whether `name` is `"Alice"`, `"Alice "` (trailing space!) or even a custom object. The repr shows the difference:

```python
print(f"name = {name!r}")     # name = 'Alice '   <-- aha, trailing space
```

**Rule 3 — print at the boundaries.** Print a function's inputs at the top and its result just before `return`. If the inputs are right and the output is wrong, the bug is inside; if the inputs are already wrong, look at the caller.

Applying this to our example:

```python hl_lines="6 9"
def count_repeated_words(sentence):
    words = sentence.split()
    counts = {}
    for word in words:
        counts[word] = counts.get(word, 0) + 1
    print(f"DEBUG counts = {counts}")

    repeated = 0
    for word, count in counts.items():
        print(f"DEBUG checking {word!r}: count={count}, count > 2 is {count > 2}")
        if count > 2:
            repeated += 1
    return repeated
```

```console
$ python3 repeats.py
DEBUG counts = {'the': 2, 'cat': 1, 'sat': 1, 'on': 1, 'mat': 1}
DEBUG checking 'the': count=2, count > 2 is False
DEBUG checking 'cat': count=1, count > 2 is False
...
0
```

Now the bug is obvious: `counts` is correct (`'the'` appears 2 times), but the condition `count > 2` should be `count >= 2` (or `count > 1`). The first loop was never the problem — without the prints, you might have stared at it for ten minutes.

## The `f"{expr=}"` shortcut

Since Python 3.8, f-strings have a debugging shortcut: `=` after an expression prints both the expression *and* its value (using its repr):

```python
x = 41
print(f"{x=}")            # x=41
print(f"{x + 1=}")        # x + 1=42
print(f"{counts=}")       # counts={'the': 2, 'cat': 1, ...}
```

This gives you Rule 1 and Rule 2 for free — use it.

## Pretty-printing big structures

For nested dicts and lists, `print()` produces an unreadable single line. Use `pprint`:

```python
from pprint import pprint
pprint(response_data)        # nicely indented, keys sorted
```

## The limits of print debugging

Print debugging starts to hurt when:

- The code runs in a **loop thousands of times** — you get thousands of lines of output.
- You need to inspect **many variables at once**, and keep adding "one more print" and re-running.
- The bug is deep in a call stack and you want to look *around* interactively.
- You have to remember to **remove all the prints** afterwards (and you'll miss one).

When you hit these limits, reach for [logging](03-logging.md) (prints you can switch on and off) or a [debugger](04-pdb.md) (no code changes, full interactive inspection).

## Exercise 2

This function should return the largest number in a list, but `largest([5, -2, -7])` returns `0` instead of `5` for some inputs... wait, actually it returns `5` there. Try `largest([-5, -2, -7])`. Use labelled prints (or `f"{...=}"`) to find out why it returns `0` instead of `-2`.

```python title="largest.py"
def largest(numbers):
    biggest = 0
    for n in numbers:
        if n > biggest:
            biggest = n
    return biggest

print(largest([-5, -2, -7]))   # expected -2, got 0
```

??? success "Solution"
    Add a print inside the loop:

    ```python
    for n in numbers:
        print(f"{n=}, {biggest=}, {n > biggest=}")
        if n > biggest:
            biggest = n
    ```

    ```text
    n=-5, biggest=0, n > biggest=False
    n=-2, biggest=0, n > biggest=False
    n=-7, biggest=0, n > biggest=False
    ```

    No element ever beats the starting value of `0`, because they're all negative. Initialising `biggest = 0` was the bug — `0` isn't in the list! Initialise from the data instead:

    ```python
    def largest(numbers):
        biggest = numbers[0]
        for n in numbers[1:]:
            if n > biggest:
                biggest = n
        return biggest
    ```

    (Or just use the built-in `max(numbers)`.)
