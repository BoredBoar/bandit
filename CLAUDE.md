# CLAUDE.md — Context for Claude Code

## Project Purpose

`bandit` is a cross-platform CLI that wraps [OverTheWire's Bandit wargame](https://overthewire.org/wargames/bandit/) in a Podman container. It provides:

- A consistent tool environment (ssh, sshpass, netcat, openssl, python3, etc.) via Podman
- Local credential management so users don't re-type passwords between sessions
- Progress tracking across all 34 levels (bandit0 → bandit33)
- Tab-completion for bash and zsh

---

## CRITICAL: No Spoilers Policy

**Never commit passwords, level solutions, or hints to git.**

The `.gitignore` contains a broad `*.json` safety net. Any JSON file that is NOT credentials (e.g. a future `levels.json` manifest) must be:
1. Added with `git add -f <file>`
2. Documented as an explicit exception in this file under "Committed JSON Files"

Currently committed JSON files: _none_

---

## Architecture

```
bandit              Main entrypoint (bash, set -euo pipefail)
lib/
  colors.sh         ANSI color variables; respects NO_COLOR + non-tty
  config.sh         Read/write passwords.json and progress.json via jq
  container.sh      Podman image build/run helpers
  ssh.sh            SSH-into-level logic (runs sshpass inside container)
  ui.sh             Banner, log functions, status table, level info
completions/
  bandit.bash       Bash tab-completion
  bandit.zsh        Zsh tab-completion (#compdef style)
Containerfile       debian:bookworm-slim image with all required tools
```

The main `bandit` script:
1. Resolves `SCRIPT_DIR` relative to its own location (makes it relocatable/symlinkable)
2. Sources all `lib/*.sh` in dependency order
3. Dispatches subcommands via a `case` statement to `cmd_<name>()` functions

---

## Data Storage

| File | Path | Permissions |
|---|---|---|
| Passwords | `~/.local/share/bandit/passwords.json` | 600 |
| Progress | `~/.local/share/bandit/progress.json` | 600 |
| SSH known_hosts | `~/.local/share/bandit/known_hosts` | 600 |
| Data directory | `~/.local/share/bandit/` | 700 |

Override the base directory with `BANDIT_DATA_DIR` for testing:
```bash
BANDIT_DATA_DIR=/tmp/bandit-test ./bandit status
```

---

## Container Design

- **Base image**: `debian:bookworm-slim` — matches the Bandit server's glibc. Do NOT switch to Alpine (musl libc produces subtly different output for tools like `strings`, `xxd`).
- **SSH runs inside the container**, not on the host. This provides `sshpass` and a pinned `ssh` client version without requiring them on the host.
- **Password passing**: The password is exported as `SSHPASS` and forwarded into the container via `podman run --env SSHPASS=...`. It is then consumed by `sshpass -e`. This avoids the password appearing in `ps aux` output (command-line args are world-readable; env vars are not).
- **SELinux**: Volume mounts use `:z` label. This is required on Fedora/RHEL hosts; silently ignored on macOS/Windows.
- **UID mapping**: `--userns=keep-id` maps the host user's UID into the container so files created inside it are owned correctly on the host.

---

## Key Environment Variables

| Variable | Default | Purpose |
|---|---|---|
| `BANDIT_DATA_DIR` | `~/.local/share/bandit` | Override data directory |
| `BANDIT_IMAGE` | `localhost/bandit:latest` | Override container image name |
| `NO_COLOR` | unset | Disable ANSI colors (respects https://no-color.org/) |
| `SSHPASS` | set internally | SSH password; never set manually |

---

## Development / Testing

```bash
# Build the container image
./bandit init

# Test credential storage without touching real data or connecting
BANDIT_DATA_DIR=/tmp/bandit-test ./bandit save 0 bandit0
BANDIT_DATA_DIR=/tmp/bandit-test ./bandit status
BANDIT_DATA_DIR=/tmp/bandit-test ./bandit info 0

# Drop into the container interactively
./bandit shell

# Run an arbitrary command in the container
./bandit run python3 --version

# Test real SSH connection (level 0 password is public: "bandit0")
./bandit connect 0

# Test tab completions
source completions/bandit.bash
bandit <TAB>
bandit connect <TAB>
```

---

## Adding a New Subcommand

1. Add a `cmd_<name>()` function in `bandit` (or source it from `lib/` if substantial)
2. Add a `<name>) cmd_<name> "$@" ;;` case in the dispatch block at the bottom of `bandit`
3. Update `cmd_help()` with a description line
4. Add the command name to both `completions/bandit.bash` (`$commands`) and `completions/bandit.zsh` (`commands` array)

---

## Bandit Game Reference

- Host: `bandit.labs.overthewire.org`  Port: `2220`
- Users: `bandit0` through `bandit33`
- Level 0 password is publicly documented: `bandit0`
- Each level's password is found by solving that level's challenge
- The tool does NOT provide hints, solutions, or passwords — users discover those themselves
