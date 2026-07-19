# Setup

You only need a few things for this tutorial.

## Requirements

- **Python 3.9 or newer** (everything here works with the standard library — no packages to install).
- A **terminal** (Terminal on macOS, PowerShell on Windows, or any Linux shell).
- **Visual Studio Code** with the **Python extension** (only needed for the [VS Code debugging](04-vscode.md) section).

## Check your Python

Open a terminal and run:

```console
$ python3 --version
Python 3.14.4
```

Any version from 3.9 up is fine.

## Create a working folder

Make a folder to hold the example scripts you'll write during the tutorial:

```console
mkdir debugging-tutorial
cd debugging-tutorial
```

## Optional: VS Code

If you want to follow the visual-debugger section:

1. Install [VS Code](https://code.visualstudio.com/).
2. Open VS Code, go to the Extensions panel (++cmd+shift+x++ on macOS, ++ctrl+shift+x++ on Windows/Linux), and install the **Python** extension published by Microsoft.
3. Open your `debugging-tutorial` folder with *File → Open Folder…*.

!!! note
    The first three sections (tracebacks, print and logging, and `pdb`) only need a terminal and a text editor — you can do them anywhere, including on a remote server over SSH. That's part of why they're worth learning even if you normally use an IDE.

That's it — head to [Reading tracebacks](01-tracebacks.md) to begin.
