#!/usr/bin/env bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Push the Python Debugging Tutorial to GitHub.
#
# The GitHub Pages site is built and deployed automatically after each
# push by .github/workflows/build_documentation.yml, which runs
# `mkdocs gh-deploy`. You do NOT need to build the docs by hand.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Always run from the folder this script lives in, so the destructive
# commands below (chmod / rm) can never touch the wrong directory.
cd "$(dirname "$0")" || exit 1

# The GitHub repository to push to (SSH):
REPO="git@github.com:geoffreyweal/python-debugging-tutorial.git"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Convert all permissions to read/write/execute for all users
chmod -R 777 *

# (Re)initialise the git repository from scratch
#rm -rf .git
#git init

# Stage and commit everything (respects .gitignore)
git add .
git commit -m 'Update Python debugging tutorial'

# Set the branch to main and point it at the remote
git branch -M main
git remote add origin "$REPO"

# Force-push to GitHub (overwrites remote history)
git push -uf origin main

# Remove the local .git folder
#rm -rf .git
