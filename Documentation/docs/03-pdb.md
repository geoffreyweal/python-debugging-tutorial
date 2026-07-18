# 3. The Python debugger (pdb)

Imagine your program is a car that won't run properly. Reading a [traceback](01-tracebacks.md) is like inspecting the car *after* it has stalled at the side of the road — you can see where it came to a stop, but not what was happening under the bonnet moment to moment. [Print statements and logs](02-print-and-logging.md) are like bolting a few extra gauges to the dashboard and reading them back after a test drive.

A **debugger** is the next level up: it's like being able to freeze the engine mid-rev, lift the bonnet while it's still turning over, and inspect any part — every dial, wire, and moving piston — *in real time*. You can watch the machinery work one step at a time, pause it at the exact moment something looks wrong, and even nudge a part to test a fix before letting it run on.

That is what a debugger does for code: it pauses your program at a point you choose and drops you into an interactive prompt where you can inspect variables, run expressions, and step through the code line by line. Python ships one in the standard library: `pdb`. It works everywhere Python works — including over SSH on a remote machine where there's no IDE.

## `breakpoint()` — the one function to remember

Since Python 3.7, you set a breakpoint by calling the built-in `breakpoint()` wherever you want the program to pause:

```python title="orders.py" hl_lines="10"
def apply_discount(price, percent):
    discount = price * percent / 100
    return price - discount

def total(order):
    result = 0
    for item, price in order.items():
        result += price
    result = apply_discount(result, order.get("discount", 0))
    breakpoint()
    return result

order = {"book": 25.00, "pen": 3.50, "discount": 10}
print(total(order))
```

Run it normally, and the program stops at the breakpoint and gives you a `(Pdb)` prompt:

```console
$ python3 orders.py
> /Users/you/orders.py(11)total()
-> return result
(Pdb)
```

The `->` line shows the **next line to be executed**. Now you can look around:

```text
(Pdb) result
25.65
(Pdb) order
{'book': 25.0, 'pen': 3.5, 'discount': 10}
```

Hmm — `25.65`? The items sum to `28.50`, minus 10% should be `25.65`... but wait, the loop also added the *discount value itself* (`10`) into the sum: `25 + 3.5 + 10 = 38.5`. Let's check:

```text
(Pdb) sum(price for item, price in order.items() if item != "discount")
28.5
```

You can run **any Python expression** at the `(Pdb)` prompt. That's the superpower: instead of adding a print, re-running, adding another print, re-running... you ask all your questions in one session.

## The essential commands

At the `(Pdb)` prompt, single letters are commands:

| Command | Long form | What it does |
|---|---|---|
| `l` | `list` | Show source code around the current line (`ll` shows the whole function). |
| `n` | `next` | Execute the current line and stop at the next one (steps *over* function calls). |
| `s` | `step` | Like `n`, but steps *into* function calls. |
| `r` | `return` | Run until the current function returns. |
| `c` | `continue` | Resume normal execution (until the next breakpoint, if any). |
| `p expr` | `print` | Evaluate and print an expression, e.g. `p result`. |
| `pp expr` | `pretty-print` | Like `p` but pretty-printed — great for dicts. |
| `w` | `where` | Show the call stack (where am I, and who called me?). |
| `u` / `d` | `up` / `down` | Move up/down the call stack to inspect the caller's variables. |
| `b 15` | `break` | Set another breakpoint at line 15. |
| `q` | `quit` | Abort the program. |
| `h` | `help` | List all commands (`h n` for help on one command). |

!!! warning "Variable names that clash with commands"
    If your variable is called `n`, `l`, `c`... typing its name runs the *command* instead. Use `p n` to print it, or prefix with `!` to force Python evaluation: `!n = 5`.

A typical session: use `w` to see where you are, `ll` to see the code, `p`/`pp` to inspect variables, `n` to walk forward a few lines watching things change, and `c` when you've seen enough.

## Stepping through the bug

Move the `breakpoint()` to the top of `total()` and walk through the loop:

```text
(Pdb) n
> orders.py(7)total()
-> for item, price in order.items():
(Pdb) n
> orders.py(8)total()
-> result += price
(Pdb) p item, price
('book', 25.0)
(Pdb) n
(Pdb) n
(Pdb) p item, price
('pen', 3.5)
(Pdb) n
(Pdb) n
(Pdb) p item, price
('discount', 10)        <-- there's the bug: the discount is being summed as a price
```

## Post-mortem debugging: inspect a crash after it happens

If your program crashes with a traceback, you can re-run it under `pdb` and be dropped into the debugger **at the moment of the crash**, with all variables intact:

```console
$ python3 -m pdb -c continue average.py
Traceback (most recent call last):
  ...
ZeroDivisionError: division by zero
Uncaught exception. Entering post mortem debugging
> average.py(2)average()
-> return sum(numbers) / len(numbers)
(Pdb) p numbers
[]
(Pdb) w      # who called us with an empty list?
```

This is often the fastest way to diagnose a crash: no code changes at all, and `w`, `u`, `p` let you inspect every frame of the failed call stack.

!!! tip "In Jupyter notebooks"
    After a cell raises an exception, run `%debug` in the next cell — you get the same post-mortem `(Pdb)` prompt at the point of failure. There's also `%pdb on` to enter it automatically on every error.

## Exercise 4

Save the `orders.py` example above, use the debugger to confirm the bug, then fix `total()` so the discount key is not summed as a price. Verify with the debugger (or a print) that the result is `25.65`.

??? success "Solution"
    ```python
    def total(order):
        result = 0
        for item, price in order.items():
            if item == "discount":
                continue
            result += price
        result = apply_discount(result, order.get("discount", 0))
        return result
    ```

    Better still, don't mix the discount into the same dict as the items — data-structure design prevents whole categories of bugs.

Prefer clicking to typing? The same concepts — breakpoints, stepping, inspecting — come with a visual interface in [VS Code](04-vscode.md).
