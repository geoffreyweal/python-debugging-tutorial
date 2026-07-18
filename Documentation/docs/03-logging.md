# 3. Logging

Print debugging has a fatal flaw: when you're done, you have to delete all the prints — and next week, when the bug comes back, you add them all again. **Logging** is the fix: debug output you can leave in your code permanently and switch on and off with one line.

## Logging in 30 seconds

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

## A realistic setup

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

## Logging exceptions

Inside an `except` block, `logger.exception(...)` logs your message **plus the full traceback** — invaluable for errors that happen occasionally in long-running programs:

```python
try:
    result = process(item)
except ValueError:
    logger.exception("failed to process item %r", item)
    # program continues, but the traceback is in the log
```

## Logging to a file

Long-running scripts (e.g. jobs on a cluster) should log to a file so you can inspect problems after the fact:

```python
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)-8s %(name)s: %(message)s",
    filename="pipeline.log",   # append to this file instead of the screen
)
```

## Print vs logging: when to use which

| Situation | Use |
|---|---|
| Quick one-off check while writing code | `print()` — then delete it |
| Diagnostic output you'll want again later | `logging.debug()` |
| Progress/status of a long-running script | `logging.info()` |
| "This shouldn't happen but isn't fatal" | `logging.warning()` |
| Output that *is the program's product* (e.g. results) | `print()` |

## Exercise 3

Take your fixed `largest.py` from the previous exercise (or the `repeats.py` example) and:

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

Next: sometimes you don't want to *read about* what happened — you want to stop the program mid-flight and poke around. That's the [Python debugger](04-pdb.md).
