# Cheat sheet

The whole tutorial on one page.

## The method

1. **Reproduce** — smallest input that triggers the bug.
2. **Read the traceback** — bottom-up: error type → crash line → call chain.
3. **Hypothesise** — one specific, testable guess.
4. **Observe** — print / log / breakpoint. Compare expectation vs. reality.
5. **Fix one thing**, re-run, repeat.
6. **Add a test** (or at least a comment) so the bug can't sneak back in.

## Tracebacks

- Read **bottom-up**: last line = what went wrong; line above = where; rest = how you got there.
- The crash site and the mistake are often in **different places** — walk up the stack.
- Two tracebacks chained together ("During handling of the above exception…") → read the **first (top)** one; that's the original problem.
- `NoneType has no attribute ...` → something returned `None` (missing `return`? in-place method like `.sort()`?).

## Print debugging

```python
print(f"{x=}")                      # prints: x=<value>  (name AND repr, Python 3.8+)
print(f"name = {name!r}")           # repr reveals strings vs numbers, stray whitespace
print(f"{x=}", flush=True)          # flush=True: never lose the last line before a crash
from pprint import pprint; pprint(big_dict)
```

- Label every print; print function **inputs and outputs**; use `!r`.

## Logging

```python
import logging
logger = logging.getLogger(__name__)

logger.debug("x=%r", x)             # diagnostic detail
logger.info("processed %d rows", n) # progress
logger.warning("...")               # unexpected but non-fatal
logger.exception("failed on %r", item)  # inside except: message + traceback

logging.basicConfig(level=logging.DEBUG)    # show everything
logging.basicConfig(level=logging.INFO)     # hide debug lines
logging.basicConfig(filename="run.log", level=logging.INFO)  # to a file
```

## pdb

```python
breakpoint()        # pause here, drop into (Pdb)
```

```console
$ python3 -m pdb -c continue script.py   # post-mortem: debugger at the crash site
```

| Command | Action |
|---|---|
| `ll` | show current function's source |
| `n` / `s` | next line / step into call |
| `r` / `c` | finish function / continue running |
| `p x` / `pp x` | print / pretty-print expression |
| `w` then `u`/`d` | show call stack, move up/down it |
| `b 15` | breakpoint at line 15 |
| `q` | quit |
| `!x = 5` | force Python statement (names that clash with commands) |

Jupyter: `%debug` in the cell after a crash.

## VS Code

- Click gutter → breakpoint; ++f5++ run; ++f10++ step over; ++f11++ step into; ++shift+f11++ step out.
- **Variables** panel = all locals live; **Watch** = expressions; **Call stack** = clickable frames.
- **Debug Console** = live Python in the paused frame.
- Right-click breakpoint → **condition** (`i == 8532`) or **logpoint** (print without pausing).
- Breakpoints panel → tick **Uncaught Exceptions** for visual post-mortem.
- Script needs arguments → `.vscode/launch.json` with `"args": [...]`.

## Bugs to recognise on sight

| Symptom | Likely bug |
|---|---|
| First/last item missing, `IndexError` | Off-by-one: `range`, slice ends, `len` vs last index |
| `TypeError` with `str` and `int` | `input()` returns strings; convert with `int()`/`float()` |
| Data leaks between function calls | Mutable default argument (`def f(x, items=[])`) |
| Variable changed "by itself" | Aliasing — `b = a` is not a copy; use `.copy()`/`deepcopy` |
| Removals from a list miss items | Modifying a list while iterating; build a new list instead |
| `'NoneType' object ...` after `.sort()` etc. | In-place method returns `None`; use `sorted()` or don't assign |
| `'list' object is not callable` | You shadowed a built-in (`list = ...`) |
| A stdlib module missing obvious attributes | You named a file after a module (`random.py`, `csv.py`) |
| Loop body runs once / too often | Indentation — check where the block really ends |
| Numeric result rounded down unexpectedly | `//` is floor division — use `/` for true division |
| `0.1 + 0.2 != 0.3` | Float rounding; use `math.isclose()` |
| Equal values compare as not-the-same | `is` tests identity, not equality — use `==`; reserve `is` for `None` |
| `ModuleNotFoundError` / `FileNotFoundError` | Wrong environment or working directory: check `sys.executable`, `os.getcwd()`, unsaved files |
