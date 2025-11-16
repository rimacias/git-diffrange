# git-diffrange

A powerful Git diff wrapper that simplifies commit range analysis, daily summaries, and reporting workflows with customizable formatting.

## Features

- **Predefined Ranges**: Quick shortcuts for current week (`-cw`) and last week (`-lw`)
- **Custom Date Ranges**: Flexible date-based commit filtering
- **Author Filtering**: Focus on specific contributor's changes (`-a`)
- **Daily Summaries**: Group commits by day with customizable formatted output (`-ds`)
- **Custom Formatters**: Full control over commit line formatting with tokens (`--ds-format`)
- **Patch Generation**: Create separate patch files per day (`-ds -p`)
- **Interactive Mode**: Browse and select commits/files with fzf (`-i`)
- **Multiple Output Formats**: `--stat`, `--name-only`, full diffs

## Use Cases

- 📊 Weekly standup reports with formatted summaries
- 🔍 Code review preparation
- 👤 Change tracking per developer
- 📅 Historical analysis by date range
- 📦 Automated patch generation for releases
- 📝 Custom commit logs for documentation

## Requirements

- Git
- Bash 3.2+ (macOS compatible)
- fzf (optional, for interactive mode only)

## Installation

### Fast install (recommended)
Use the helper script to install the git alias automatically:

```bash
chmod +x git-alias-install.sh
./git-alias-install.sh
# After this, use it as:
git diffrange -h
```

What it does:
- Copies `.git-diffrange` to `~/.git-diffrange`
- Makes it executable
- Sets `git config --global alias.diffrange '!~/.git-diffrange'`
- Prompts before overwriting

### Manual install options

```bash
chmod +x .git-diffrange

# Option 1: Symlink to /usr/local/bin (recommended if you prefer PATH over alias)
ln -sf "$(pwd)/.git-diffrange" /usr/local/bin/git-diffrange
# Usage: git-diffrange -h (as a standalone command)

# Option 2: Add repo dir to PATH (shell startup)
echo "export PATH=\"$PATH:$(pwd)\"" >> ~/.zshrc
source ~/.zshrc
# Usage: git-diffrange -h (if you kept the filename)

# Option 3: Copy into PATH
cp .git-diffrange /usr/local/bin/git-diffrange
# Usage: git-diffrange -h

# Option 4: Git alias (manual)
cp .git-diffrange ~/.git-diffrange
git config --global alias.diffrange '!~/.git-diffrange'
# Usage: git diffrange -h
```

Tip: The git alias approach lets you run `git diffrange` directly under the `git` CLI, no PATH changes needed.

## Quick Start

```bash
# Show changes from this week
git diffrange -cw

# Show last week's changes grouped by day
git diffrange -lw -ds

# Show current week for specific author with custom format
git diffrange -cw -a john --ds-format '%s (%h) — %an'

# Generate daily patch files for last week
git diffrange -lw -ds -p -n "sprint-23"

# Custom date range
git diffrange 2024-01-01 2024-01-31 -ds
```

### Pager tip (seeing all output)
Some environments open a pager for long output. Pipe to cat to always see results:

```bash
git diffrange -cw -ds | cat
# Or disable pager globally for git logs if you prefer:
# git config --global core.pager cat
```

## Usage

```bash
git diffrange [options] [date] [date]
```

### Predefined Ranges

| Flag | Description |
|------|-------------|
| `-cw`, `--current-week` | Changes from Monday (of current week) to now |
| `-lw`, `--last-week` | Changes from last Monday to last Sunday |

### Custom Date Ranges

```bash
# Single date (from that date to now)
git diffrange 2024-01-01

# Date range (from start to end)
git diffrange 2024-01-01 2024-12-31
```

Supported date formats: `YYYY-MM-DD`

### Core Options

| Option | Description |
|--------|-------------|
| `-a`, `--author <name>` | Filter commits by author (case-insensitive, matches name or email) |
| `-ds` | Enable daily summary mode (groups commits by day) |
| `-ds=format{...}` | Daily summary with inline format (e.g., `-ds='format{%h %s}'`) |
| `--daily-summary[=format{...}]` | Same as `-ds` (long form) |
| `--ds-format '<format>'` | Specify custom format for commit lines (recommended for complex formats) |
| `-p`, `--patch` | Generate diff patches (creates per-day .patch files when used with `-ds`) |
| `-n`, `--name <label>` | Name prefix for daily patch files (default: "report") |
| `-i` | Interactive mode using fzf (incompatible with `-ds`) |
| `-h`, `--help` | Show basic help |
| `-fh`, `--formatter-help` | Show detailed formatter documentation |

### Output Options

| Option | Description |
|--------|-------------|
| `--stat` | Show only statistics (files changed, insertions, deletions) |
| `--name-only` | Show only names of changed files |
| `-p`, `--patch` | Show full diff with patch format (default when no output option specified) |

## Daily Summary Mode (`-ds`)

The daily summary mode groups commits by day and presents them in an organized format.

### Basic Daily Summary

```bash
# Current week summary
git diffrange -cw -ds

# Output:
# Daily Summary (10/11/2024 - 14/11/2024)
# 
# 10/11/2024:
#   • Fixed navigation bug (a3b4c5d)
#   • Updated dependencies (e7f6a51)
# 
# 11/11/2024:
#   • Added new feature X (9d8e7f6)
```

### Custom Formatting

Use `git diffrange -fh` for full formatter docs and examples.

Three ways to pass a format:

```bash
# 1) Short inline
git diffrange -cw -ds='format{%h %s}'

# 2) Long inline
git diffrange -cw --daily-summary='format{[%ad] %an: %s}'

# 3) Dedicated flag (best for spaces/special chars)
git diffrange -cw -ds --ds-format ' • %s (%h) — %an'
```

Tokens: `%h %H %s %an %ae %ad %n`. On zsh/macOS, quote formats with spaces:

```bash
git diffrange -cw --ds-format '%s (%h)'
git diffrange -cw -ds='format{%s (%h)}'
```

## Author filtering behavior

- Matching is case-insensitive and uses substring search on:
  - author name/email and committer name/email
  - Co-authored-by trailers in the commit body
- Example: `-a cando` matches `sucre-cando-fairmatic`, `kevincando@dev`, etc.
- The date window is enforced strictly in daily summary results.

## Advanced Usage Examples

```bash
# Weekly standup report for your user
git diffrange -lw -a "$(git config user.name)" -ds --ds-format '✓ %s'

# Between tags, formatted for release notes
git diffrange v1.0.0 v1.1.0 -ds --ds-format '- %s (%an)'

# Per-day patch files for code review
git diffrange -cw -ds -p -n "code-review"
```

## Interactive Mode

When using `-i` with `fzf` installed you can pick FROM/TO commits and an optional file to diff. Note: incompatible with `-ds`.

## Behavior Details

- Commit lookup uses Monday/Sunday boundaries for week ranges (macOS `date -v`)
- Day headers use `dd/mm/YYYY`; `%ad` tokens in format lines use `YYYY-MM-DD`
- Internally uses an ASCII field separator to keep parsing safe
- Unknown format tokens are left unchanged (e.g., `%x` remains `%x`)

## Formatter Help

Run:

```bash
git diffrange -fh
# or
git diffrange --formatter-help
```

This prints full docs: tokens, quoting, examples, edge cases, and quick try-it commands.
