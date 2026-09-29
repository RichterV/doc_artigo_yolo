#!/usr/bin/env bash
# Build the MkDocs site and commit/push the documentation to GitHub.
#
# Usage:
#   ./commit.sh                   # default commit message with timestamp
#   ./commit.sh "my message"      # custom commit message
#
# mkdocs is installed automatically into ./.venv on first run (via uv, or
# python3 -m venv as a fallback).
#
# Only documentation files are committed. The paper (.docx), the loose images
# and the linux/ code/data folder are left out on purpose (see FILES below).

set -euo pipefail

REMOTE_URL="https://github.com/RichterV/doc_artigo_yolo.git"
BRANCH="main"
MESSAGE="${1:-docs: update documentation ($(date '+%Y-%m-%d %H:%M'))}"
VENV=".venv"

FILES=(
  README.md
  mkdocs.yml
  requirements.txt
  requirements-docs.txt
  commit.sh
  .gitignore
  .github
  docs
  site
)

# Keep the window open when the script is started by double-click,
# so success or error messages can be read.
pause_on_exit() {
  local status=$?
  echo
  if [ "$status" -ne 0 ]; then
    echo "commit.sh FAILED (exit code $status). See the messages above."
  else
    echo "commit.sh finished."
  fi
  if [ -t 0 ]; then
    read -r -p "Press Enter to close..." _
  fi
}
trap pause_on_exit EXIT

cd "$(dirname "$0")"

# 1. Make sure mkdocs is available (local virtualenv)
if [ ! -x "$VENV/bin/mkdocs" ]; then
  echo "==> Installing mkdocs into $VENV"
  UV="$(command -v uv || true)"
  if [ -z "$UV" ] && [ -x "$HOME/.local/bin/uv" ]; then
    UV="$HOME/.local/bin/uv"
  fi

  if [ -n "$UV" ]; then
    "$UV" venv -q "$VENV"
    "$UV" pip install -q --python "$VENV/bin/python" -r requirements-docs.txt
  elif python3 -m venv "$VENV" 2>/dev/null; then
    "$VENV/bin/pip" install -q -r requirements-docs.txt
  else
    echo "Could not create a virtualenv: install uv or python3-venv." >&2
    exit 1
  fi
fi

# 2. Build the site (fails on broken links/warnings)
echo "==> Building site"
"$VENV/bin/mkdocs" build --strict --clean

# GitHub Pages serves "main / (root)": copy the built site to the repository
# root (index.html takes precedence over README.md) and disable Jekyll.
echo "==> Copying built site to repository root"
cp -r site/. ./
touch .nojekyll
FILES+=(.nojekyll)
for item in site/*; do
  FILES+=("$(basename "$item")")
done

# 3. Initialise the repository on first use
if [ ! -d .git ]; then
  echo "==> Initialising git repository"
  git init
fi

if [ ! -f .gitignore ]; then
  printf '%s\n' '/*.docx' '/*.jpeg' '/linux/' '__pycache__/' '.venv/' '*Zone.Identifier' > .gitignore
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin "$REMOTE_URL"
fi

# 4. Stage, commit and push
echo "==> Committing"
git add -- "${FILES[@]}"

if git diff --cached --quiet; then
  echo "Nothing to commit."
  exit 0
fi

git commit -m "$MESSAGE"
git branch -M "$BRANCH"

echo "==> Pushing to $REMOTE_URL ($BRANCH)"
git push -u origin "$BRANCH"
