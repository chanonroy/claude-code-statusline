# claude-code-statusline

A custom status line script for [Claude Code](https://claude.ai/code).

## What it shows

```
~/my-project | main(+2) | Sonnet 4.6 | Context: [████░░░░░░] 35% • high /effort
```

- **Directory** — current working directory (`~/` style)
- **Git branch** — branch name with dirty file count (e.g. `main(+3)`)
- **Model** — active Claude model
- **Context bar** — visual progress bar (green → orange → red as context fills)
- **Effort** — current `/effort` level

## Setup

1. Copy `statusline-command.sh` to `~/.claude/`:

```sh
cp statusline-command.sh ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh
```

2. Add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash /Users/YOUR_USERNAME/.claude/statusline-command.sh"
  }
}
```

Replace `YOUR_USERNAME` with your macOS username.
