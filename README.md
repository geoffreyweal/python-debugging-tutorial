# Python Debugging Tutorial

A hands-on workshop for learning how to debug Python code, built with [MkDocs](https://www.mkdocs.org/) and the [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) theme.

## Viewing the tutorial locally

```bash
pip install mkdocs-material
cd Documentation
mkdocs serve
```

Then open <http://127.0.0.1:8000> in your browser. The page live-reloads as you edit the Markdown files.

## Structure

```
Documentation/
├── mkdocs.yml          # site configuration and navigation
└── docs/
    ├── index.md            # welcome + the debugging method
    ├── setup.md            # requirements
    ├── 01-tracebacks.md    # reading error messages
    ├── 02-print-and-logging.md  # print debugging and the logging module
    ├── 03-pdb.md           # breakpoint() and the built-in debugger
    ├── 04-vscode.md        # the VS Code visual debugger
    ├── 05-common-bugs.md   # bug patterns to recognise on sight
    ├── exercises.md        # three larger buggy programs to fix
    └── cheatsheet.md       # one-page summary
```

## Deployment

Pushing to `main`/`master` triggers the GitHub Actions workflow in
`.github/workflows/build_documentation.yml`, which builds the site and
publishes it to GitHub Pages via `mkdocs gh-deploy`.
