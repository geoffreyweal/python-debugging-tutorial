# 4. Debugging in VS Code

VS Code's visual debugger is `pdb`'s concepts with a friendlier interface: breakpoints are red dots, the call stack is a panel, and every local variable is visible at once without typing `p`.

Make sure you've done the [setup](setup.md#optional-vs-code): VS Code + the Microsoft Python extension, with your tutorial folder open.

## Your first debugging session

1. Open a buggy script — the `orders.py` example from the [pdb section](03-pdb.md) works well (remove the `breakpoint()` line first).
2. **Set a breakpoint**: click in the gutter (the space left of the line numbers) next to the first line of `total()`. A red dot appears.
3. **Start debugging**: press ++f5++ (or *Run → Start Debugging*). When asked for a configuration, choose **Python File**.
4. Execution pauses at your breakpoint. The line is highlighted, and the debugging UI appears.

## The debugging UI

Once paused, look at the left-hand panel:

- **Variables** — every local and global variable and its current value, live. Expand dicts and lists to explore them. This alone replaces most print statements.
- **Watch** — add an expression (e.g. `len(order)` or `result * 0.9`) and it's re-evaluated every time you pause.
- **Call stack** — the chain of function calls, like the traceback / `w` in pdb. Click any frame to see *that* function's variables.
- **Breakpoints** — all breakpoints in the workspace; tick/untick to enable/disable.

Along the top, the **debug toolbar** mirrors the pdb commands:

| Button | Key | pdb equivalent | What it does |
|---|---|---|---|
| Continue | ++f5++ | `c` | Run until the next breakpoint. |
| Step Over | ++f10++ | `n` | Execute this line, don't descend into calls. |
| Step Into | ++f11++ | `s` | Descend into the function being called. |
| Step Out | ++shift+f11++ | `r` | Finish the current function and pause in the caller. |
| Restart | ++cmd+shift+f5++ / ++ctrl+shift+f5++ | — | Start the run again. |
| Stop | ++shift+f5++ | `q` | Kill the program. |

## The Debug Console

While paused, the **Debug Console** tab (bottom panel) is a live Python prompt in the current frame — exactly like typing expressions at `(Pdb)`. Try:

```python
sum(price for item, price in order.items() if item != "discount")
```

You can even modify variables (`result = 28.5`) and continue, to test "would the fix work?" before editing any code.

## Conditional breakpoints

Suppose a loop runs 10,000 times and only iteration 8,532 misbehaves. Don't press ++f5++ 8,532 times:

1. **Right-click** the red breakpoint dot → **Edit Breakpoint…**
2. Choose **Expression** and enter a condition, e.g. `item == "discount"` or `i == 8532`.

The debugger now only pauses when the condition is true. There's also **Hit Count** (pause on the Nth hit) and **Log Message** (a "logpoint": prints a message *without pausing* — print debugging with no code changes!).

## Breaking on exceptions

In the **Breakpoints** panel, tick **Uncaught Exceptions**. Now, if the program crashes, the debugger pauses *at the crash site* with all variables inspectable — the visual version of pdb's post-mortem mode. Tick **Raised Exceptions** to pause on *every* raise, even handled ones (noisy, but occasionally invaluable).

## Debugging with command-line arguments

If your script needs arguments (`python3 analyse.py data.csv --fast`), create a launch configuration:

1. *Run → Add Configuration…* → **Python File**. This creates `.vscode/launch.json`.
2. Add an `args` entry:

```json title=".vscode/launch.json"
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Analyse with data.csv",
            "type": "debugpy",
            "request": "launch",
            "program": "${workspaceFolder}/analyse.py",
            "console": "integratedTerminal",
            "args": ["data.csv", "--fast"]
        }
    ]
}
```

++f5++ now runs with those arguments every time.

!!! tip "Which Python is it using?"
    The debugger uses the interpreter shown in VS Code's status bar (bottom-right). If imports fail in the debugger but work in your terminal, you're probably running two different Pythons — click the interpreter name and select the right environment.

## Exercise 5

Take `repeats.py` from the [print debugging section](02-print-and-logging.md) (the original, unfixed version, with your prints removed):

1. Set a breakpoint on the `if count > 2:` line.
2. Press ++f5++ and watch `word` and `count` in the **Variables** panel each time you hit **Continue**.
3. In the **Debug Console**, evaluate `count > 2` and `count >= 2` when `word` is `"the"`.
4. Fix the bug, remove the breakpoint, and re-run to confirm.

Now that you have four observation tools — tracebacks, prints, logs, and debuggers — let's look at the [most common bugs](05-common-bugs.md) you'll point them at.
