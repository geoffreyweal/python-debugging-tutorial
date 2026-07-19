# 1. Reading tracebacks

When Python crashes, it prints a **traceback**. Beginners often ignore it or only read the first line — but the traceback usually tells you *exactly* where the problem is. Learning to read it is the single highest-value debugging skill.

## Anatomy of a traceback

Save this as `average.py`:

```python title="average.py"
def average(numbers):
    return sum(numbers) / len(numbers)

def report(scores):
    avg = average(scores)
    print(f"The average score is {avg:.1f}")

report([])
```

Run it:

```console
$ python3 average.py
Traceback (most recent call last):
  File "average.py", line 8, in <module>
    report([])
  File "average.py", line 5, in report
    avg = average(scores)
  File "average.py", line 2, in average
    return sum(numbers) / len(numbers)
ZeroDivisionError: division by zero
```

Read it like this:

| Part | What it tells you |
|---|---|
| `Traceback (most recent call last):` | A traceback follows; the **last** entry is where the error happened. |
| The stack of `File "...", line N, in ...` entries | The chain of function calls that led to the crash, from the top of the program down. |
| The final line: `ZeroDivisionError: division by zero` | The **type** of error and a message explaining it. |

So, read the traceback **from the bottom up**: 

1. The last line says *what* went wrong: a division by zero.
2. The entry just above it says *where*: line 2, inside `average`.
3. The entries above that say *how you got there*: `report([])` was called with an empty list, so `len(numbers)` was `0`.

The crash happened in `average`, but the *cause* was further up: someone passed an empty list. This distinction — **where it crashed vs. where the mistake was made** — is the heart of debugging.

!!! tip "Python 3.11+ points at the exact expression"
    Recent Python versions underline the exact part of the line that failed with `~~~^~~~` markers, which is especially helpful when a line contains several operations, e.g. `data["users"][0]["name"]`.

## Common error types

You'll see these constantly. Knowing what each one *usually* means speeds you up enormously:

| Error | Typical meaning |
|---|---|
| `SyntaxError` | Python couldn't even parse the file — look at (or just *before*) the reported line for missing colons, brackets, or quotes. |
| `IndentationError` | Inconsistent indentation, often mixed tabs and spaces. |
| `NameError` | You used a variable/function name that doesn't exist — usually a typo or something defined later/elsewhere. |
| `TypeError` | You used a value of the wrong type, e.g. `"3" + 4` or calling something that isn't a function. |
| `ValueError` | Right type, wrong value, e.g. `int("hello")`. |
| `IndexError` | List index out of range — classic off-by-one. |
| `KeyError` | Dictionary key doesn't exist — print the dict's keys to see what *is* there. |
| `AttributeError` | The object doesn't have that attribute/method — often means the variable isn't the type you thought it was (e.g. it's `None`). |
| `FileNotFoundError` | Wrong path, or you're running the script from a different folder than you think. |
| `ModuleNotFoundError` | The package isn't installed *in the Python environment you're running* — check `which python3` / your virtual environment. |
| `ZeroDivisionError` | A denominator was zero — ask *why* it was zero. |

!!! warning "`AttributeError: 'NoneType' object has no attribute ...`"
    This specific message is so common it deserves a call-out. It means a variable is `None` when you expected a real object. Common causes: a function that **forgot to `return`** (Python returns `None` by default), or a method like `list.sort()` that modifies in place and returns `None`:

    ```python
    numbers = [3, 1, 2].sort()   # numbers is None!
    numbers = sorted([3, 1, 2])  # correct
    ```

## Chained exceptions

Sometimes you'll see two tracebacks joined by:

```text
During handling of the above exception, another exception occurred:
```

or

```text
The above exception was the direct cause of the following exception:
```

Read the **first (top) traceback** — that's the original problem. The second one happened while handling the first.

## Exercise 1

Save this file as `broken.py` and fix all three bugs, one at a time. Run it after each fix and read the new traceback.

```python title="broken.py"
def greet(name)
    message = "Hello, " + name + "!"
    return mesage

people = ["Alice", "Bob", "Charlie"]
print(greet(people[3]))
```

??? success "Solution"
    1. **`SyntaxError`** — missing colon after `def greet(name)`.
    2. **`IndexError: list index out of range`** — the list has indices 0–2, so `people[3]` doesn't exist. Use `people[2]` (or any valid index).
    3. **`NameError: name 'mesage' is not defined`** — typo: `mesage` should be `message`.

    ```python
    def greet(name):
        message = "Hello, " + name + "!"
        return message

    people = ["Alice", "Bob", "Charlie"]
    print(greet(people[2]))
    ```

Next up: what to do when your program *doesn't* crash but still gives the wrong answer — [print debugging](02-print-and-logging.md).
