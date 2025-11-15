#!/usr/bin/env bash
set -euo pipefail

# git-alias-install.sh
# Installs .git-diffrange into the user's home and registers a git alias
# Usage: ./git-alias-install.sh [path-to-.git-diffrange]

usage() {
  cat <<EOF
Usage: $0 [PATH_TO_.git-diffrange]

If PATH is omitted, the script will look for .git-diffrange in the
current working directory and in the script's directory.

This script will:
  - copy the .git-diffrange file to ~/.git-diffrange
  - make it executable
  - register a git alias 'diffrange' that runs "~/.git-diffrange"

It will prompt before overwriting existing files or changing your git config.
EOF
}

# Find source file
SRC_CANDIDATE="${1-}"
if [[ -z "$SRC_CANDIDATE" ]]; then
  # try cwd then script dir
  if [[ -f "./.git-diffrange" ]]; then
    SRC_CANDIDATE="$(pwd)/.git-diffrange"
  else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
    if [[ -f "$SCRIPT_DIR/.git-diffrange" ]]; then
      SRC_CANDIDATE="$SCRIPT_DIR/.git-diffrange"
    fi
  fi
fi

if [[ -z "$SRC_CANDIDATE" || ! -f "$SRC_CANDIDATE" ]]; then
  echo "Error: .git-diffrange not found. Pass the path as the first argument or run this from the repo root." >&2
  usage
  exit 2
fi

DEST="$HOME/.git-diffrange"

# Confirm overwrite if exists
if [[ -f "$DEST" ]]; then
  echo "A file already exists at $DEST"
  read -r -p "Overwrite it? [y/N]: " answer
  case "$answer" in
    [Yy]*) true ;;
    *) echo "Aborting."; exit 0 ;;
  esac
fi

# Copy file preserving mode and timestamps
cp -p "$SRC_CANDIDATE" "$DEST"
chmod +x "$DEST"

# Ensure git exists
if ! command -v git >/dev/null 2>&1; then
  echo "Warning: git command not found. Skipping git alias creation. File installed at $DEST"
  echo "You can create the alias later with: git config --global alias.diffrange '!$DEST'"
  exit 0
fi

# Register git alias using git config --global
EXISTING_ALIAS=$(git config --global --get alias.diffrange || true)
if [[ "$EXISTING_ALIAS" == "!$DEST" ]]; then
  echo "Git alias 'diffrange' already set to '!$DEST'"
else
  if [[ -n "$EXISTING_ALIAS" ]]; then
    echo "A git alias 'diffrange' already exists with value: $EXISTING_ALIAS"
    read -r -p "Overwrite existing git alias? [y/N]: " answer
    case "$answer" in
      [Yy]*) git config --global alias.diffrange "!$DEST" ;;
      *) echo "Alias left unchanged. To set it manually: git config --global alias.diffrange '!$DEST'"; exit 0 ;;
    esac
  else
    git config --global alias.diffrange "!$DEST"
  fi
  echo "Git alias 'diffrange' set to: $(git config --global --get alias.diffrange)"
fi
echo ""
echo "Installation complete. You can now run: git diffrange [options]"

exit 0

