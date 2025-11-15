# git-diffrange

A comprehensive Git diff wrapper that simplifies commit range analysis and reporting workflows.

## Features

- **Predefined Ranges**: Quick shortcuts for current week (`-cw`) and last week (`-lw`)
- **Custom Date Ranges**: Flexible date-based commit filtering
- **Author Filtering**: Focus on specific contributor's changes (`-a`)
- **Daily Summaries**: Group commits by day with formatted output (`-ds`)
- **Patch Generation**: Create separate patch files per day (`-ds -p`)
- **Interactive Mode**: Browse and select commits/files with fzf (`-i`)
- **Multiple Output Formats**: `--stat`, `--name-only`, full diffs

## Use Cases

- Weekly standup reports
- Code review preparation
- Change tracking per developer
- Historical analysis by date range
- Automated patch generation for releases

## Requirements

- Git
- Bash 3.2+ (macOS compatible)
- fzf (optional, for interactive mode)
