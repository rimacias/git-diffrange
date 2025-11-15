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

1. Clone or download the script:
```bash
git clone https://github.com/yourusername/git-diffrange.git
cd git-diffrange
```

2. Make it executable and add to your PATH:
```bash
chmod +x .git-diffrange
# Option 1: Symlink to a directory in your PATH
ln -s "$(pwd)/.git-diffrange" /usr/local/bin/git-diffrange

# Option 2: Or use git's custom command feature
ln -s "$(pwd)/.git-diffrange" /usr/local/bin/git-diffrange
# Now you can use: git diffrange
```

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

You can customize how each commit line appears using format tokens.

#### Three Ways to Specify Format

1. **Inline with `-ds`** (short):
```bash
git diffrange -cw -ds='format{%h %s}'
```

2. **Inline with `--daily-summary`** (long):
```bash
git diffrange -cw --daily-summary='format{[%ad] %an: %s}'
```

3. **Dedicated flag** (recommended for complex formats):
```bash
git diffrange -cw -ds --ds-format ' • %s (%h) — %an'
```

#### Format Tokens

| Token | Description | Example |
|-------|-------------|---------|
| `%h` | Short commit hash | `e7f6a51` |
| `%H` | Full commit hash (40 chars) | `e7f6a512abc...` |
| `%s` | Commit subject (title) | `Fixed navigation bug` |
| `%an` | Author name | `John Doe` |
| `%ae` | Author email | `john@example.com` |
| `%ad` | Commit date | `2024-11-14` |
| `%n` | Newline (line break) | (creates new line) |

#### Format Examples

**Default format** (if not specified):
```bash
--ds-format ' • %s (%h)'
# Output: • Fixed bug (e7f6a51)
```

**Minimal - just hashes:**
```bash
-ds='format{%H%n}'
# Output: e7f6a512abc123def456...
```

**Subject with author:**
```bash
--ds-format '%s (%h) — %an'
# Output: Fixed bug (e7f6a51) — John Doe
```

**Multi-line detailed:**
```bash
--ds-format '%s%n  by %an <%ae>%n  %H%n'
# Output:
# Fixed bug
#   by John Doe <john@example.com>
#   e7f6a512abc123def456...
```

**Date-prefixed:**
```bash
--ds-format '[%ad] %s — %ae'
# Output: [2024-11-14] Fixed bug — john@example.com
```

**No indentation (plain subjects):**
```bash
--ds-format '%s'
# Output: Fixed bug
```

### Shell Quoting Tips (zsh/macOS)

**Always quote formats with spaces:**
```bash
# ✅ Good
git diffrange -cw --ds-format '%s (%h)'
git diffrange -cw -ds='format{%s (%h)}'

# ❌ Bad (won't work correctly)
git diffrange -cw --ds-format %s (%h)
```

**For special characters, use single quotes:**
```bash
git diffrange -cw --ds-format ' • %s (%h) — %an'
```

### Daily Summary with Patches

Generate separate patch files for each day:

```bash
git diffrange -lw -ds -p -n "sprint-23"
```

This creates:
- Console output: Daily summary with commit groupings
- Files in `diff_reports/`:
  - `10-11-2024_sprint-23.patch`
  - `11-11-2024_sprint-23.patch`
  - `12-11-2024_sprint-23.patch`
  - etc.

Each patch file contains all the diffs for that specific day.

## Advanced Usage Examples

### Weekly Standup Report

```bash
# Show your work from last week with clean formatting
git diffrange -lw -a $(git config user.name) -ds --ds-format '✓ %s'
```

### Release Notes Generation

```bash
# Get all commits between two tags
git diffrange v1.0.0 v1.1.0 -ds --ds-format '- %s (%an)'
```

### Code Review Preparation

```bash
# Get patches for each day to review separately
git diffrange -cw -ds -p -n "code-review"
```

### Author Comparison

```bash
# Compare two developers' contributions
git diffrange -lw -a alice -ds --ds-format '👤 Alice: %s'
git diffrange -lw -a bob -ds --ds-format '👤 Bob: %s'
```

### Detailed Commit Audit

```bash
# Multi-line format with full details
git diffrange 2024-11-01 2024-11-14 -ds --ds-format '%s%n  Author: %an <%ae>%n  Date: %ad%n  Hash: %H%n'
```

### Interactive File Review

```bash
# Browse commits and select specific files to review
git diffrange -cw -i
```

## Interactive Mode

When using `-i` flag with `fzf` installed:

1. Select the **FROM** commit using fuzzy search
2. Select the **TO** commit
3. Optionally select a specific file (or ESC for full diff)
4. View the resulting diff

**Note:** Interactive mode is incompatible with `-ds` (daily summary).

## Output Examples

### Standard Diff Output

```bash
git diffrange -cw
```
Shows traditional `git diff` output with changes between Monday and now.

### Statistics Only

```bash
git diffrange -cw --stat
```
```
 src/app.js           | 23 ++++++++++++++-------
 src/utils/helper.js  |  5 +++--
 README.md            | 42 ++++++++++++++++++++++++++++++--------
 3 files changed, 53 insertions(+), 17 deletions(-)
```

### File Names Only

```bash
git diffrange -lw --name-only
```
```
src/app.js
src/utils/helper.js
README.md
tests/app.test.js
```

## Behavior Details

### Commit Lookup
- The script finds the **last commit before** the specified date
- For week ranges, it uses Monday 00:00 as start and Sunday 23:59 (or now) as end
- Author filtering is case-insensitive and matches both name and email

### Daily Summary Grouping
- Commits are grouped by date (YYYY-MM-DD)
- Within each day, commits are listed chronologically (earliest first)
- Day headers use dd/mm/YYYY format
- Empty days are not shown

### Patch Generation
- Patches are saved to `diff_reports/` directory (auto-created)
- Filename format: `dd-mm-YYYY_<name>.patch`
- Each patch contains the full diff for that day
- Empty patches (no changes) are automatically removed

### Safety
- Uses ASCII separator internally to handle special characters in commit messages
- Properly handles commits with quotes, newlines, and Unicode characters
- Unknown format tokens are left unchanged (e.g., `%x` stays as `%x`)

## Formatter Help

For comprehensive documentation on custom formatting, run:

```bash
git diffrange -fh
# or
git diffrange --formatter-help
```

This displays:
- All supported format tokens (`%h`, `%H`, `%s`, `%an`, `%ae`, `%ad`, `%n`)
- How to pass custom formats (three methods)
- Shell quoting best practices for zsh/macOS
- Multiple real-world examples
- Edge cases and tips
- Quick try-it commands

### Quick Formatter Reference

**Available tokens:**
- `%h` - short hash
- `%H` - full hash
- `%s` - subject/title
- `%an` - author name
- `%ae` - author email
- `%ad` - date (YYYY-MM-DD)
- `%n` - newline

**Three ways to set format:**
```bash
# Method 1: Inline short
-ds='format{%h %s}'

# Method 2: Inline long
--daily-summary='format{%h %s}'

# Method 3: Dedicated flag (best for spaces)
--ds-format '%s (%h) — %an'
```

## Edge Cases and Tips

### Literal Percent Signs
Any `%` not followed by a known token stays as-is:
```bash
--ds-format '%s completed 100%% (%h)'
# Output: Feature X completed 100% (e7f6a51)
```

### Newline Handling
Using `%n` at the end creates blank lines between commits:
```bash
--ds-format '%s (%h)%n'
# Output:
# Fixed bug (e7f6a51)
# 
# Added feature (a3b4c5d)
```

### Empty Results
If no commits match your criteria:
```
(Sin commits en el rango)
```

### Author Matching
The `-a` flag matches partial names and emails:
```bash
# All of these will match "John Doe <john.doe@example.com>":
-a john
-a doe
-a john.doe
-a example.com
```

## Troubleshooting

### No commits found
- Check that your date range is correct
- Verify the author name is spelled correctly
- Ensure there are commits in that time range: `git log --since="YYYY-MM-DD"`

### fzf not found (interactive mode)
Install fzf on macOS:
```bash
brew install fzf
```

### Format not working as expected
- Make sure to quote your format string if it contains spaces
- Check that you're using supported tokens (`%h`, `%H`, `%s`, `%an`, `%ae`, `%ad`, `%n`)
- Use `git diffrange -fh` to see the detailed formatter help

### Patches not generated
- Ensure you're using `-p` flag with `-ds`
- Check that there are actual changes in the date range
- Verify write permissions in the current directory

## Getting More Help

```bash
# Basic help
git diffrange -h

# Detailed formatter documentation
git diffrange -fh
```

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

MIT License - See LICENSE file for details

## Credits

Created for streamlined Git workflow management and reporting.

