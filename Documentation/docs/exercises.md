# Exercises

Three progressively harder buggy programs. For each one: copy it into a file, reproduce the problem, and fix it using whichever techniques you prefer — tracebacks, prints, logging, `pdb`, or the VS Code debugger. Try to *diagnose before you fix*: state what you think is wrong, then verify it by observation.

Hints and solutions are collapsed — try honestly before peeking!

---

## Exercise A: The grade reporter *(crashes)*

This script should print each student's average grade. It crashes.

```python title="grades.py"
students = {
    "Aroha": [78, 85, 92],
    "Ben": [55, 61, 70],
    "Chen": [],
    "Dana": [90, 88],
}

def average(marks):
    return sum(marks) / len(marks)

def print_report(students):
    for name in students:
        avg = average(students[name])
        print(f"{name}: {avg:.1f}")

print_report(students)
```

??? hint "Hint 1"
    Run it and read the traceback bottom-up. What error, what line, and — going up the stack — which student was being processed?

??? hint "Hint 2"
    Post-mortem debugging shines here: `python3 -m pdb -c continue grades.py`, then `p marks` and `w`.

??? success "Solution"
    `ZeroDivisionError` in `average`, because Chen has no marks — `len(marks)` is `0`. The crash is in `average` but the *decision* about what an empty list means belongs to the caller. One fix:

    ```python
    def print_report(students):
        for name in students:
            marks = students[name]
            if not marks:
                print(f"{name}: no marks recorded")
                continue
            print(f"{name}: {average(marks):.1f}")
    ```

---

## Exercise B: The word counter *(wrong answer)*

This script should count word frequencies in a piece of text, ignoring case and punctuation, and print the top 3. It runs without errors — but the counts are wrong: `"the"` should appear 4 times, yet it's reported 3 times, and `"cat!"` appears as its own word.

```python title="wordcount.py"
text = "The cat sat on the mat. The dog saw the cat! The end."

def count_words(text):
    counts = {}
    words = text.split()
    for word in words:
        word = word.strip(".,!?")
        counts[word] = counts.get(word, 0) + 1
    return counts

def top_words(counts, n):
    ranked = sorted(counts, key=counts.get, reverse=True)
    return ranked[1:n]

counts = count_words(text)
for word in top_words(counts, 3):
    print(word, counts[word])
```

??? hint "Hint 1"
    There are **two** bugs. For the first: print `counts` (use `pprint`!) and look carefully at the keys. `"The"` and `"the"`...

??? hint "Hint 2"
    For the second: `top_words` is asked for the top 3 but returns 2 words — and not the two you'd expect. Look very carefully at the slice.

??? success "Solution"
    1. **Case is never ignored** — `"The"` and `"the"` are counted separately. Add `word = word.lower()` (this also handles why the count was 3 not 4).
    2. **Off-by-one in the slice** — `ranked[1:n]` skips the most frequent word and returns only `n-1` items. It should be `ranked[:n]`.

    ```python
    def count_words(text):
        counts = {}
        for word in text.split():
            word = word.strip(".,!?").lower()
            counts[word] = counts.get(word, 0) + 1
        return counts

    def top_words(counts, n):
        ranked = sorted(counts, key=counts.get, reverse=True)
        return ranked[:n]
    ```

    (If `"cat!"` still shows up as its own word for you, check you kept the `strip` — and note `strip` only removes from the ends, which is fine here.)

---

## Exercise C: The lab-results pipeline *(subtle)*

This script processes a week of sensor readings: it removes obviously bad readings (negative values), converts to Fahrenheit for a US collaborator, and reports each day's readings alongside the original data. It runs — but the "original" data has been mangled, and Tuesday's report is missing a reading that should have survived the cleaning.

```python title="pipeline.py"
readings = {
    "Mon": [18.2, 19.1, -99.0, 20.3],
    "Tue": [17.8, -99.0, -99.0, 18.9],
    "Wed": [21.0, 22.4, 21.7, 23.1],
}

def clean(day_readings):
    for r in day_readings:
        if r < 0:
            day_readings.remove(r)
    return day_readings

def to_fahrenheit(day_readings):
    return [c * 9 / 5 + 32 for c in day_readings]

def report(readings):
    for day, day_readings in readings.items():
        cleaned = clean(day_readings)
        fahrenheit = to_fahrenheit(cleaned)
        print(f"{day}: {len(cleaned)} readings, F = {fahrenheit}")

report(readings)
print("Original data:", readings)
```

??? hint "Hint 1"
    Two classic bugs from the [common bugs](05-common-bugs.md) page are working together here. First: step through `clean(["17.8", ...])` — sorry, `clean([17.8, -99.0, -99.0, 18.9])` — with a debugger, one `n` at a time, watching `day_readings` in the Variables panel (or `p day_readings` in pdb). What happens to the *second* `-99.0` when the first one is removed?

??? hint "Hint 2"
    Second bug: `clean` never copies. Whose list is it modifying?

??? success "Solution"
    1. **Modifying a list while iterating over it.** When the first `-99.0` is removed, the list shifts left and the loop skips the element that moved into its place — the second consecutive `-99.0` survives... actually watch closely: the *skipped* element here is the second `-99.0`, so Tuesday keeps a bad reading. Consecutive bad values are exactly the case this pattern gets wrong.
    2. **Aliasing.** `clean` mutates the caller's list in place, so the "original" `readings` printed at the end has been modified.

    Fix both by building a new list:

    ```python
    def clean(day_readings):
        return [r for r in day_readings if r >= 0]
    ```

    Now `clean` neither skips elements nor touches the original data. One list comprehension, two bugs gone — *not mutating things you don't own* is a deep principle, not just a style preference.

---

## Where to go from here

- Run `python3 -m pdb yourscript.py` on your own real code next time it misbehaves.
- Read the [cheat sheet](cheatsheet.md) — it condenses this whole tutorial onto one page.
- When you fix a real bug, take 60 seconds to ask: *what observation would have found this faster?* That reflection is how debugging skill compounds.
