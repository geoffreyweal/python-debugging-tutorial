# 5. Common bugs to look out for

Most bugs are not exotic. The same dozen mistakes account for a huge share of real-world Python debugging time. Knowing them by sight means you'll often recognise the bug the moment you observe the symptom.

## Off-by-one errors

`range(n)` gives `0` to `n-1`; slices exclude the end point; `len(x)` is one more than the last valid index. Any of these mixed up produces a loop that misses the last item, processes one too many, or raises `IndexError`.

```python
scores = [10, 20, 30]
for i in range(1, len(scores)):   # oops: starts at 1, skips scores[0]
    print(scores[i])
```

**Symptom:** first/last item mysteriously missing, or `IndexError`.
**Defence:** iterate directly (`for score in scores:`) whenever you don't truly need the index; if you need both, use `enumerate(scores)`.

## Integer vs. float division, and string vs. number

```python
half = 5 // 2        # 2, not 2.5 — // is floor division
age = input("Age? ") # input() ALWAYS returns a string
next_year = age + 1  # TypeError: can only concatenate str to str
```

**Symptom:** `TypeError` mentioning `str` and `int`, or numeric results that are slightly off.
**Defence:** convert at the boundary: `age = int(input("Age? "))`. Print with `!r` to see whether a value is `5` or `"5"`.

## Mutable default arguments

The default value is created **once**, when the function is defined — not on every call:

```python
def add_item(item, items=[]):     # one shared list for ALL calls!
    items.append(item)
    return items

add_item("a")     # ['a']
add_item("b")     # ['a', 'b']  <-- surprise
```

**Symptom:** data "leaking" between calls that should be independent.
**Defence:** use `None` as the default:

```python
def add_item(item, items=None):
    if items is None:
        items = []
    ...
```

## Aliasing: two names, one object

Assignment never copies. `b = a` makes `b` point at the *same* list/dict as `a`:

```python
original = [1, 2, 3]
copy = original          # NOT a copy
copy.append(4)
print(original)          # [1, 2, 3, 4]  <-- modified through the other name
```

**Symptom:** a variable changes when you "didn't touch it".
**Defence:** `copy = list(original)` or `original.copy()`; for nested structures, `copy.deepcopy()`.

## Modifying a list while iterating over it

```python
numbers = [1, 2, 3, 4, 5, 6]
for n in numbers:
    if n % 2 == 0:
        numbers.remove(n)     # skips elements as the list shifts underneath
print(numbers)                # [1, 3, 5] here, but this pattern misses items in general
```

**Symptom:** some items that should have been removed survive.
**Defence:** build a new list instead: `numbers = [n for n in numbers if n % 2 != 0]`.

## In-place methods that return `None`

```python
names = ["Charlie", "Alice", "Bob"]
names = names.sort()      # sort() sorts in place and returns None
print(names[0])           # AttributeError / TypeError: 'NoneType' ...
```

**Symptom:** `'NoneType' object has no attribute ...` or `is not subscriptable`.
**Defence:** either `names.sort()` (no assignment) or `names = sorted(names)`. Same trap with `.append()`, `.reverse()`, `random.shuffle()`.

## Shadowing built-ins and modules

```python
list = [1, 2, 3]        # you've just destroyed the built-in list()
data = list(range(5))   # TypeError: 'list' object is not callable
```

Also: naming your own file `random.py` or `csv.py` shadows the standard-library module — `import random` imports *your file* instead, causing baffling `AttributeError`s.

**Symptom:** `'X' object is not callable`, or a standard module missing obvious attributes.
**Defence:** don't use built-in/module names (`list`, `dict`, `sum`, `max`, `input`, `random`, `csv`...) for variables or filenames.

## Indentation changing meaning

```python
total = 0
for n in [1, 2, 3]:
    total += n
    print(total)      # inside the loop: prints 1, 3, 6
print(total)          # outside the loop: prints 6 once
```

Both versions are valid Python — only the indentation says which you meant. A `return` accidentally indented *inside* a loop is a classic: the function returns after the first iteration.

**Symptom:** loop runs once, or something happens N times that should happen once.
**Defence:** when a loop misbehaves, check the indentation of its last lines first.

## `==` vs `is`, and floating-point equality

```python
if answer == True: ...    # works, but just write: if answer:
if x is 1000: ...         # DON'T: `is` tests identity, not equality

0.1 + 0.2 == 0.3          # False! floating-point rounding
```

**Defence:** use `==` for value comparison, `is` only for `None`. For floats, use `math.isclose(a, b)`.

## The wrong file / the wrong environment

Not all bugs are in the code. Frequently the code is fine and you are:

- editing one file but running another copy;
- running an old version because you forgot to save (VS Code shows a dot ● on unsaved tabs);
- in a different working directory than you think (`FileNotFoundError` for a file that "is right there");
- using a different Python/venv than the one with your packages (`ModuleNotFoundError`).

**Defence:** add `print("running", __file__)` at the top when confused; check `import os; print(os.getcwd())`; check `import sys; print(sys.executable)`.

## Exercise 5

Each snippet below contains one bug from this page. Identify it *before* running the code, then verify with any technique you like.

```python title="snippet_a.py"
def register(user, groups=[]):
    groups.append("everyone")
    return {"user": user, "groups": groups}

print(register("alice"))
print(register("bob"))
```

```python title="snippet_b.py"
def find_word(words, target):
    for i, word in enumerate(words):
        if word == target:
            return i
        return -1

print(find_word(["red", "green", "blue"], "blue"))
```

```python title="snippet_c.py"
temperatures = ["18.5", "21.0", "19.2"]
average = sum(temperatures) / len(temperatures)
print(average)
```

??? success "Solutions"
    - **A:** mutable default argument — `bob`'s groups list already contains `alice`'s `"everyone"`. Use `groups=None` + `if groups is None: groups = []`.
    - **B:** indentation — `return -1` is inside the loop, so the function gives up after checking only the first word. Dedent it to line up with `for`.
    - **C:** strings, not numbers — `sum()` on strings raises `TypeError`. Convert first: `temps = [float(t) for t in temperatures]`.

You now have the full toolkit. Put it to work on the [exercises](exercises.md).
