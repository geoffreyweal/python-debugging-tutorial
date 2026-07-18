# 2. Print and logging

The simplest debugging technique: put `print()` statements in your code to see what's actually happening. Everyone does it, it works everywhere, and done *well* it's genuinely effective.

This page covers two closely related techniques: quick, throwaway **`print()` debugging**, and **`logging`** — the same idea made permanent and switchable. We'll start with prints.

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

## Prints help even when the program *does* crash

Print debugging isn't only for silent, wrong-answer bugs — it's just as useful when you *do* get a traceback. A [traceback](01-tracebacks.md) tells you **where** the program crashed and **what type** of error it was, but usually not the **values** that led it there. A `print()` placed just before the crashing line fills that gap.

Here `normalise` divides by the largest reading, which blows up on an all-zero dataset:

```python title="scale.py"
def scale(values, factor):
    return [v * factor for v in values]

def normalise(readings):
    biggest = max(readings)
    return scale(readings, 1 / biggest)

datasets = [[3, 8, 5], [0, 0, 0], [2, 9, 4]]
for data in datasets:
    print(normalise(data))
```

The traceback ends with `ZeroDivisionError: division by zero` and points at the `1 / biggest` line — but *which* of the three datasets caused it? Add one print to find out:

```python hl_lines="3"
def normalise(readings):
    biggest = max(readings)
    print(f"DEBUG normalise: {readings=}, {biggest=}", flush=True)
    return scale(readings, 1 / biggest)
```

```console
$ python3 scale.py
DEBUG normalise: readings=[3, 8, 5], biggest=8
[0.375, 1.0, 0.625]
DEBUG normalise: readings=[0, 0, 0], biggest=0
Traceback (most recent call last):
  ...
ZeroDivisionError: division by zero
```

The **last `DEBUG` line before the traceback** is your prime suspect: the all-zero dataset made `biggest` zero. The traceback showed the *symptom*; the print showed the *cause*.

!!! tip "Add `flush=True` when a crash might swallow your output"
    Normal `print()` output is buffered, while the traceback is written separately. If you redirect output to a file (`python3 scale.py > log.txt 2>&1`), a crash can cut off buffered prints or reorder them relative to the traceback. Passing `flush=True` forces each line out immediately, so your last-known-state print is never lost.

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

## The limits of print debugging

Print debugging starts to hurt when:

- The code runs in a **loop thousands of times** — you get thousands of lines of output.
- You need to inspect **many variables at once**, and keep adding "one more print" and re-running.
- The bug is deep in a call stack and you want to look *around* interactively.
- You have to remember to **remove all the prints** afterwards (and you'll miss one).

When you hit these limits, reach for **logging** (prints you can switch on and off — the rest of this page) or a [debugger](03-pdb.md) (no code changes, full interactive inspection).

## Logging: prints you don't have to delete

The last of those limits — hunting down every `print` when you're done, then re-adding them next week when the bug comes back — is the one **logging** removes for good. Logging is diagnostic output you can leave in your code permanently and switch on and off with a single line.

### Logging in 30 seconds

```python title="basic_logging.py"
import logging

logging.basicConfig(level=logging.DEBUG)

logging.debug("Detailed diagnostic info")
logging.info("Something normal happened")
logging.warning("Something unexpected, but we can continue")
logging.error("Something failed")
logging.critical("The program cannot continue")
```

```console
$ python3 basic_logging.py
DEBUG:root:Detailed diagnostic info
INFO:root:Something normal happened
WARNING:root:Something unexpected, but we can continue
ERROR:root:Something failed
CRITICAL:root:The program cannot continue
```

The five **levels** are the whole trick. Each message has a level, and `basicConfig(level=...)` sets the minimum level that gets shown:

- With `level=logging.DEBUG` you see everything — this is "debugging mode".
- With `level=logging.WARNING` (the default) the `debug` and `info` messages vanish — this is "normal mode".

So instead of deleting your debug prints, you write them as `logging.debug(...)` and just change one line when you're done.

### A realistic setup

In real code, create a **logger per module** and include timestamps in the format:

```python title="pipeline.py"
import logging

logger = logging.getLogger(__name__)

def clean(record):
    logger.debug("cleaning record: %r", record)
    result = record.strip().lower()
    logger.debug("cleaned to: %r", result)
    return result

def run(records):
    logger.info("processing %d records", len(records))
    cleaned = []
    for record in records:
        if not record.strip():
            logger.warning("skipping empty record")
            continue
        cleaned.append(clean(record))
    logger.info("done: %d records kept", len(cleaned))
    return cleaned

if __name__ == "__main__":
    logging.basicConfig(
        level=logging.DEBUG,
        format="%(asctime)s %(levelname)-8s %(name)s: %(message)s",
    )
    run(["  Alpha ", "", "BETA"])
```

```console
$ python3 pipeline.py
2026-07-18 15:30:01,123 INFO     __main__: processing 3 records
2026-07-18 15:30:01,123 DEBUG    __main__: cleaning record: '  Alpha '
2026-07-18 15:30:01,123 DEBUG    __main__: cleaned to: 'alpha'
2026-07-18 15:30:01,124 WARNING  __main__: skipping empty record
2026-07-18 15:30:01,124 DEBUG    __main__: cleaning record: 'BETA'
2026-07-18 15:30:01,124 DEBUG    __main__: cleaned to: 'beta'
2026-07-18 15:30:01,124 INFO     __main__: done: 2 records kept
```

Change `level=logging.DEBUG` to `level=logging.INFO` and the noisy per-record lines disappear, while the useful summary lines stay. That's the pay-off.

!!! tip "Use `%r` / lazy formatting in log calls"
    `logger.debug("record: %r", record)` (with `%r` and the value as a separate argument) is preferred over an f-string here for two reasons: `%r` shows the repr (so you spot stray whitespace), and the string is only formatted **if the message will actually be shown**, which matters in hot loops.

### Logging exceptions

Inside an `except` block, `logger.exception(...)` logs your message **plus the full traceback** — invaluable for errors that happen occasionally in long-running programs:

```python
try:
    result = process(item)
except ValueError:
    logger.exception("failed to process item %r", item)
    # program continues, but the traceback is in the log
```

### Logging to a file

Long-running scripts (e.g. jobs on a cluster) should log to a file so you can inspect problems after the fact:

```python
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)-8s %(name)s: %(message)s",
    filename="pipeline.log",   # append to this file instead of the screen
)
```

### Print vs logging: when to use which

| Situation | Use |
|---|---|
| Quick one-off check while writing code | `print()` — then delete it |
| Diagnostic output you'll want again later | `logging.debug()` |
| Progress/status of a long-running script | `logging.info()` |
| "This shouldn't happen but isn't fatal" | `logging.warning()` |
| Output that *is the program's product* (e.g. results) | `print()` |

## Exercise 3

Take your fixed `largest.py` from [Exercise 2](#exercise-2) (or the `repeats.py` example) and:

1. Replace every debug `print` with `logger.debug(...)`.
2. Add a `logger.info(...)` line summarising the result.
3. Run it once with `level=logging.DEBUG` and once with `level=logging.INFO`, and confirm the debug lines switch off.

??? success "Solution (for `largest.py`)"
    ```python
    import logging

    logger = logging.getLogger(__name__)

    def largest(numbers):
        biggest = numbers[0]
        for n in numbers[1:]:
            logger.debug("n=%r, biggest=%r", n, biggest)
            if n > biggest:
                biggest = n
        logger.info("largest of %d numbers is %r", len(numbers), biggest)
        return biggest

    if __name__ == "__main__":
        logging.basicConfig(level=logging.DEBUG)   # switch to logging.INFO to quieten
        print(largest([-5, -2, -7]))
    ```

Next: sometimes you don't want to *read about* what happened — you want to stop the program mid-flight and poke around. That's the [Python debugger](03-pdb.md).
